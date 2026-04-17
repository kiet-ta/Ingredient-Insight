-- ============================================
-- RecipeBoard Widget (Dai tu UX/UI)
-- ============================================

local _G = GLOBAL

local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local ICON_SIZE = 60
local GRID_COLS = 4
local MAX_ROWS = 2
local ITEMS_PER_PAGE = GRID_COLS * MAX_ROWS
local PADDING = 10
local BG_PADDING = 20
local TITLE_SPACE = 32
local FOOTER_SPACE = 28
local NAV_SCALE = 0.62
local NAV_HITBOX_SCALE = 1.15
local NAV_TEXTURE_SIZE = 64
local NAV_HITBOX_SIZE = NAV_TEXTURE_SIZE * NAV_HITBOX_SCALE
local DUPLICATE_CLICK_WINDOW = 0.05

local DEBUG_LOG = true

local function Dbg(msg)
    if DEBUG_LOG then
        print("[IngredientInsight] " .. tostring(msg))
    end
end

local DEFAULT_BG_ATLAS = "images/ui.xml"
local DEFAULT_BG_TEX = "blank.tex"

local BG_CANDIDATES = {
    { atlas = "images/global_panels.xml", tex = "panel.tex" },
    { atlas = "images/ui.xml", tex = "panel_light.tex" },
    { atlas = "images/ui.xml", tex = "blank.tex" },
}

local function CreateSafeImageButton(parent, atlas, tex)
    local ok, button = pcall(function()
        return parent:AddChild(ImageButton(atlas, tex))
    end)
    if ok and button then
        return button
    end
    return nil
end

local function CreateSafeNavButton(parent)
    return CreateSafeImageButton(parent, "images/ui.xml", "scroll_arrow.tex")
end

local function CreateSafeNavHitbox(parent)
    return CreateSafeImageButton(parent, "images/ui.xml", "blank.tex")
end

local function CreateSafeImage(parent, atlas, tex)
    local ok, image = pcall(function()
        return parent:AddChild(Image(atlas, tex))
    end)
    if ok and image then
        return image
    end
    return nil
end

local function CreateSafeBackground(parent)
    for _, candidate in ipairs(BG_CANDIDATES) do
        local image = CreateSafeImage(parent, candidate.atlas, candidate.tex)
        if image then
            return image
        end
    end

    -- Last-resort fallback expected to exist in DST UI assets.
    return parent:AddChild(Image(DEFAULT_BG_ATLAS, DEFAULT_BG_TEX))
end

local function IsWidgetOrDescendant(widget, root)
    while widget do
        if widget == root then
            return true
        end
        widget = widget.parent
    end
    return false
end

local function GetTimeSeconds()
    return _G.GetTime and _G.GetTime() or 0
end

local function ConfigureNavSurface(surface, owner, action, source_name)
    if not surface then
        return
    end

    surface.page_action = action

    if surface.SetControl then
        surface:SetControl(_G.CONTROL_PRIMARY)
    end

    if surface.SetClickable then
        surface:SetClickable(true)
    end

    surface:SetOnDown(function()
        owner:HandlePageAction(action, true, source_name .. "_down")
    end)

    surface:SetOnClick(function()
        owner:HandlePageAction(action, false, source_name .. "_click")
    end)
end

local function ConfigureNavHitbox(hitbox, visual_button)
    if not hitbox then
        return
    end

    hitbox:ForceImageSize(NAV_HITBOX_SIZE, NAV_HITBOX_SIZE)
    hitbox.scale_on_focus = false
    hitbox.move_on_click = false
    hitbox.stopclicksound = true

    if hitbox.SetImageNormalColour then
        hitbox:SetImageNormalColour(1, 1, 1, 0)
        hitbox:SetImageFocusColour(1, 1, 1, 0)
        hitbox:SetImageDisabledColour(1, 1, 1, 0)
        hitbox:SetImageSelectedColour(1, 1, 1, 0)
    end

    hitbox.OnGainFocus = function()
        if visual_button and visual_button.OnGainFocus then
            visual_button:OnGainFocus()
        end
    end

    hitbox.OnLoseFocus = function()
        if visual_button and visual_button.OnLoseFocus then
            visual_button:OnLoseFocus()
        end
    end
end

local RecipeBoard = Class(Widget, function(self, owner)
    Widget._ctor(self, "RecipeBoard")
    self.owner = owner
    self.recipe_items = {}
    self.nav_buttons = {}
    self.nav_hitboxes = {}
    self:SetClickable(true)

    self.full_recipe_list = {}
    self.current_page = 1
    self.total_pages = 1
    self.selected_recipe_name = ""
    self._ii_nav_pressed_action = nil
    self._ii_last_handled_action = nil
    self._ii_last_handled_time = -math.huge

    self.bg = self:AddChild(Widget("background"))
    self.bg_image = CreateSafeBackground(self.bg)
    self.bg_image:SetTint(0.05, 0.05, 0.05, 0.95)

    self.icon_container = self:AddChild(Widget("icon_container"))
    self.icon_container:MoveToFront()

    self.selected_text = self:AddChild(Text(UIFONT, 40, ""))
    self.selected_text:SetSize(52)
    self.selected_text:SetColour(0.95, 0.95, 0.95, 1)
    self.selected_text:Hide()

    self.page_text = self:AddChild(Text(UIFONT, 20, ""))
    self.page_text:SetSize(24)
    self.page_text:SetColour(0.95, 0.85, 0.35, 1)
    self.page_text:Hide()

    local prev_button = CreateSafeNavButton(self)
    if prev_button then
        prev_button:SetScale(NAV_SCALE)
        ConfigureNavSurface(prev_button, self, "prev", "prev_button")
        prev_button:Hide()
        self.prev_button = prev_button
        table.insert(self.nav_buttons, prev_button)
    end

    local prev_hitbox = CreateSafeNavHitbox(self)
    if prev_hitbox then
        ConfigureNavHitbox(prev_hitbox, prev_button)
        ConfigureNavSurface(prev_hitbox, self, "prev", "prev_hitbox")
        prev_hitbox:Hide()
        self.prev_hitbox = prev_hitbox
        table.insert(self.nav_hitboxes, prev_hitbox)
    end

    local next_button = CreateSafeNavButton(self)
    if next_button then
        next_button:SetScale(NAV_SCALE)
        ConfigureNavSurface(next_button, self, "next", "next_button")
        next_button:Hide()
        self.next_button = next_button
        table.insert(self.nav_buttons, next_button)
    end

    local next_hitbox = CreateSafeNavHitbox(self)
    if next_hitbox then
        ConfigureNavHitbox(next_hitbox, next_button)
        ConfigureNavSurface(next_hitbox, self, "next", "next_hitbox")
        next_hitbox:Hide()
        self.next_hitbox = next_hitbox
        table.insert(self.nav_hitboxes, next_hitbox)
    end

    self:Hide()
end)

local function BuildDisplayName(recipe_data)
    if recipe_data and recipe_data.display_name and recipe_data.display_name ~= "" then
        return recipe_data.display_name
    end
    if recipe_data and recipe_data.prefab then
        return tostring(recipe_data.prefab)
    end
    return ""
end

function RecipeBoard:SetHoveredRecipe(recipe_data)
    self.selected_recipe_name = BuildDisplayName(recipe_data)
    if self.selected_recipe_name ~= "" then
        self.selected_text:SetString(self.selected_recipe_name)
        self.selected_text:Show()
    else
        self.selected_text:Hide()
    end
end

function RecipeBoard:SetRecipes(recipe_list)
    if not recipe_list or type(recipe_list) ~= "table" or #recipe_list == 0 then
        self:Hide()
        return
    end

    self._ii_nav_pressed_action = nil
    self.full_recipe_list = recipe_list
    self.total_pages = math.ceil(#recipe_list / ITEMS_PER_PAGE)
    self.current_page = 1
    self:SetHoveredRecipe(recipe_list[1])

    self:ShowPage(self.current_page)
end

function RecipeBoard:ShowPage(page_num)
    self:Clear()
    if not self.full_recipe_list then return end

    local start_idx = (page_num - 1) * ITEMS_PER_PAGE + 1
    local end_idx = math.min(page_num * ITEMS_PER_PAGE, #self.full_recipe_list)

    local items_to_show = (end_idx - start_idx) + 1
    if items_to_show <= 0 then return end

    local actual_cols = math.min(items_to_show, GRID_COLS)
    local actual_rows = math.ceil(items_to_show / GRID_COLS)

    local text_space = FOOTER_SPACE
    local width = (GRID_COLS * ICON_SIZE) + ((GRID_COLS - 1) * PADDING) + (2 * BG_PADDING)
    local height = (actual_rows * ICON_SIZE) + ((actual_rows - 1) * PADDING) + (2 * BG_PADDING) + TITLE_SPACE + text_space

    self.bg_image:SetSize(width, height)

    local BOTTOM_ANCHOR = 170
    self:SetPosition(0, BOTTOM_ANCHOR + (height / 2), 0)

    local start_x = -(width / 2) + BG_PADDING + (ICON_SIZE / 2)
    local start_y = (height / 2) - BG_PADDING - TITLE_SPACE - (ICON_SIZE / 2)

    self.selected_text:SetPosition(0, (height / 2) - BG_PADDING - (TITLE_SPACE * 0.5), 0)

    local grid_index = 0
    for i = start_idx, end_idx do
        local recipe_data = self.full_recipe_list[i]
        if recipe_data and recipe_data.prefab and recipe_data.atlas and recipe_data.image then
            local icon_widget = CreateSafeImageButton(self.icon_container, recipe_data.atlas, recipe_data.image)
            if icon_widget then
                icon_widget:SetScale(ICON_SIZE / 64)
                icon_widget.recipe_data = recipe_data

                local old_gain = icon_widget.OnGainFocus
                icon_widget.OnGainFocus = function(btn)
                    if old_gain then old_gain(btn) end
                    self:SetHoveredRecipe(recipe_data)
                end

                local col = grid_index % GRID_COLS
                local row = math.floor(grid_index / GRID_COLS)

                local current_x = start_x + (col * (ICON_SIZE + PADDING))
                local current_y = start_y - (row * (ICON_SIZE + PADDING))

                icon_widget:SetPosition(current_x, current_y, 0)
                table.insert(self.recipe_items, icon_widget)
                grid_index = grid_index + 1
            end
        end
    end

    if self.total_pages > 1 then
        self.page_text:SetString(string.format("Page %d/%d", self.current_page, self.total_pages))
        self.page_text:SetPosition(0, -(height / 2) + 20, 0)
        self.page_text:Show()

        if self.prev_button then
            self.prev_button:SetPosition(-(width / 2) + 20, -(height / 2) + 20, 0)
            self.prev_button:Show()
            self.prev_button:MoveToFront()
        end

        if self.prev_hitbox then
            self.prev_hitbox:SetPosition(-(width / 2) + 20, -(height / 2) + 20, 0)
            self.prev_hitbox:Show()
            self.prev_hitbox:MoveToFront()
        end

        if self.next_button then
            self.next_button:SetPosition((width / 2) - 20, -(height / 2) + 20, 0)
            self.next_button:Show()
            self.next_button:MoveToFront()
        end

        if self.next_hitbox then
            self.next_hitbox:SetPosition((width / 2) - 20, -(height / 2) + 20, 0)
            self.next_hitbox:Show()
            self.next_hitbox:MoveToFront()
        end

        self.page_text:MoveToFront()
    else
        self.page_text:Hide()
        if self.prev_button then self.prev_button:Hide() end
        if self.next_button then self.next_button:Hide() end
        if self.prev_hitbox then self.prev_hitbox:Hide() end
        if self.next_hitbox then self.next_hitbox:Hide() end
    end
end

function RecipeBoard:NextPage()
    if self.total_pages > 1 then
        self.current_page = self.current_page + 1
        if self.current_page > self.total_pages then self.current_page = 1 end
        Dbg("NextPage -> " .. tostring(self.current_page) .. "/" .. tostring(self.total_pages))
        self:ShowPage(self.current_page)
    end
end

function RecipeBoard:PrevPage()
    if self.total_pages > 1 then
        self.current_page = self.current_page - 1
        if self.current_page < 1 then self.current_page = self.total_pages end
        Dbg("PrevPage -> " .. tostring(self.current_page) .. "/" .. tostring(self.total_pages))
        self:ShowPage(self.current_page)
    end
end

function RecipeBoard:Clear()
    if not self.recipe_items then return end
    for _, icon_widget in ipairs(self.recipe_items) do
        if icon_widget and icon_widget.inst then icon_widget:Kill() end
    end
    self.recipe_items = {}
end

function RecipeBoard:GetHoveredPageAction()
    local hud_entity = _G.TheInput and _G.TheInput:GetHUDEntityUnderMouse() or nil
    local hovered_widget = hud_entity and hud_entity.widget or nil
    if not hovered_widget then
        return nil
    end

    if self.prev_hitbox and IsWidgetOrDescendant(hovered_widget, self.prev_hitbox) then
        return "prev"
    end

    if self.next_hitbox and IsWidgetOrDescendant(hovered_widget, self.next_hitbox) then
        return "next"
    end

    if self.prev_button and IsWidgetOrDescendant(hovered_widget, self.prev_button) then
        return "prev"
    end

    if self.next_button and IsWidgetOrDescendant(hovered_widget, self.next_button) then
        return "next"
    end

    return nil
end

function RecipeBoard:HandlePageAction(action, down, source_name)
    if self.total_pages <= 1 then
        if not down then
            self._ii_nav_pressed_action = nil
        end
        return false
    end

    if down then
        if not action then
            self._ii_nav_pressed_action = nil
            return false
        end

        self._ii_nav_pressed_action = action
        return true
    end

    if not action then
        if self._ii_nav_pressed_action ~= nil then
            Dbg("Page release consumed without turn (" .. tostring(source_name) .. ")")
            self._ii_nav_pressed_action = nil
            return true
        end
        return false
    end

    local now = GetTimeSeconds()
    if self._ii_last_handled_action == action and (now - self._ii_last_handled_time) <= DUPLICATE_CLICK_WINDOW then
        return true
    end

    local pending_action = self._ii_nav_pressed_action
    self._ii_nav_pressed_action = nil

    if pending_action ~= nil and pending_action ~= action then
        Dbg("Page release mismatch " .. tostring(pending_action) .. " -> " .. tostring(action) .. " (" .. tostring(source_name) .. ")")
        return true
    end

    self._ii_last_handled_action = action
    self._ii_last_handled_time = now

    if action == "prev" then
        Dbg("Prev button clicked (" .. tostring(source_name) .. ")")
        self:PrevPage()
        return true
    end

    if action == "next" then
        Dbg("Next button clicked (" .. tostring(source_name) .. ")")
        self:NextPage()
        return true
    end

    return false
end

function RecipeBoard:OnMouseButton(button, down, x, y)
    if not self.shown then
        return false
    end

    if button ~= _G.MOUSEBUTTON_LEFT then
        return false
    end

    return self:HandlePageAction(self:GetHoveredPageAction(), down, "board_mouse")
end

function RecipeBoard:OnControl(control, down)
    if RecipeBoard._base.OnControl(self, control, down) then
        return true
    end

    if not self.shown then
        return false
    end

    if control ~= _G.CONTROL_ACCEPT or not (_G.TheFrontEnd and _G.TheFrontEnd.isprimary) then
        return false
    end

    return self:HandlePageAction(self:GetHoveredPageAction(), down, "board_control")
end

function RecipeBoard:OnDestroy()
    self:Clear()
    RecipeBoard._base.OnDestroy(self)
end

return RecipeBoard
