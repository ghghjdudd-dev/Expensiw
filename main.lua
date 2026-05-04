--[[ 
	EXPENSIW - Beautiful Expense Tracker UI for Roblox
	Роблокс приложение для отслеживания расходов
	Created: 2026-05-04
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURATION & THEME
-- ============================================
local CONFIG = {
	THEME = {
		PRIMARY = Color3.fromRGB(88, 166, 255),      -- Синий
		SECONDARY = Color3.fromRGB(255, 154, 88),    -- Оранжевый
		SUCCESS = Color3.fromRGB(76, 175, 80),       -- Зелёный
		WARNING = Color3.fromRGB(255, 193, 7),       -- Жёлтый
		ERROR = Color3.fromRGB(244, 67, 54),         -- Красный
		DARK_BG = Color3.fromRGB(20, 20, 30),        -- Тёмный фон
		CARD_BG = Color3.fromRGB(35, 35, 50),        -- Фон карточки
		TEXT_PRIMARY = Color3.fromRGB(255, 255, 255), -- Основной текст
		TEXT_SECONDARY = Color3.fromRGB(180, 180, 200), -- Вторичный текст
	},
	PADDING = UDim.new(0, 16),
	CORNER_RADIUS = 12,
	ANIMATION_SPEED = 0.3,
}

-- ============================================
-- MOCK DATA & STATE
-- ============================================
local AppState = {
	currentPage = "dashboard",
	expenses = {
		{id = 1, name = "Кофе", amount = 5.50, category = "Еда", date = "2026-05-04", icon = "☕"},
		{id = 2, name = "Метро", amount = 2.50, category = "Транспорт", date = "2026-05-04", icon = "🚇"},
		{id = 3, name = "Книга", amount = 25.00, category = "Развлечение", date = "2026-05-03", icon = "📚"},
		{id = 4, name = "Ужин", amount = 45.00, category = "Еда", date = "2026-05-03", icon = "🍽️"},
	},
	budgets = {
		{category = "Еда", limit = 200, spent = 80.50},
		{category = "Транспорт", limit = 100, spent = 25.50},
		{category = "Развлечение", limit = 150, spent = 50.00},
		{category = "Прочее", limit = 200, spent = 120.00},
	},
	totalBalance = 1250.75,
	monthlyExpenses = 275.00,
}

-- ============================================
-- UI UTILITIES & HELPERS
-- ============================================
local UIUtils = {}

function UIUtils:CreateInstance(className, properties)
	local instance = Instance.new(className)
	if properties then
		for prop, value in pairs(properties) do
			instance[prop] = value
		end
	end
	return instance
end

function UIUtils:AddCorner(frame, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or CONFIG.CORNER_RADIUS)
	corner.Parent = frame
	return corner
end

function UIUtils:AddShadow(frame)
	local shadow = Instance.new("UIStroke")
	shadow.Color = Color3.fromRGB(0, 0, 0)
	shadow.Thickness = 2
	shadow.Transparency = 0.7
	shadow.Parent = frame
end

function UIUtils:Tween(object, info, properties)
	local tween = TweenService:Create(object, info, properties)
	tween:Play()
	return tween
end

function UIUtils:AnimateIn(frame)
	frame.GroupTransparency = 1
	frame.Position = frame.Position + UDim2.new(0, -30, 0, 0)
	
	self:Tween(frame, TweenInfo.new(CONFIG.ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = 0,
		Position = frame.Position + UDim2.new(0, 30, 0, 0),
	})
end

-- ============================================
-- UI COMPONENTS
-- ============================================
local UIComponents = {}

function UIComponents:CreateCard(parent, title, size, position)
	local card = UIUtils:CreateInstance("Frame", {
		Name = title,
		BackgroundColor3 = CONFIG.THEME.CARD_BG,
		BorderSizePixel = 0,
		Size = size or UDim2.new(1, -32, 0, 150),
		Position = position or UDim2.new(0, 16, 0, 0),
		Parent = parent,
	})
	
	UIUtils:AddCorner(card, CONFIG.CORNER_RADIUS)
	UIUtils:AddShadow(card)
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = CONFIG.PADDING
	padding.PaddingBottom = CONFIG.PADDING
	padding.PaddingLeft = CONFIG.PADDING
	padding.PaddingRight = CONFIG.PADDING
	padding.Parent = card
	
	return card
end

function UIComponents:CreateTitle(parent, text)
	local title = UIUtils:CreateInstance("TextLabel", {
		Name = "Title",
		Text = text,
		TextSize = 20,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 30),
		Parent = parent,
	})
	return title
end

function UIComponents:CreateButton(parent, text, size, position, color, callback)
	local button = UIUtils:CreateInstance("TextButton", {
		Name = "Button",
		Text = text,
		TextSize = 15,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundColor3 = color or CONFIG.THEME.PRIMARY,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Size = size or UDim2.new(1, -32, 0, 45),
		Position = position or UDim2.new(0, 16, 0, 100),
		Parent = parent,
	})
	
	UIUtils:AddCorner(button, 8)
	
	button.MouseEnter:Connect(function()
		UIUtils:Tween(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromHSV(color:ToHSV() * Color3.new(1, 0.9, 1.1))
		})
	end)
	
	button.MouseLeave:Connect(function()
		UIUtils:Tween(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = color or CONFIG.THEME.PRIMARY
		})
	end)
	
	button.Activated:Connect(function()
		if callback then callback() end
	end)
	
	return button
end

function UIComponents:CreateStatBox(parent, title, value, unit, color, size, position)
	local box = self:CreateCard(parent, title, size or UDim2.new(0.5, -24, 0, 120), position)
	box.BackgroundColor3 = color or CONFIG.THEME.CARD_BG
	
	local titleLabel = UIUtils:CreateInstance("TextLabel", {
		Name = "StatTitle",
		Text = title,
		TextSize = 14,
		TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, 0, 0, 20),
		Parent = box,
	})
	
	local valueLabel = UIUtils:CreateInstance("TextLabel", {
		Name = "StatValue",
		Text = value,
		TextSize = 28,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 25),
		Parent = box,
	})
	
	if unit then
		local unitLabel = UIUtils:CreateInstance("TextLabel", {
			Name = "Unit",
			Text = unit,
			TextSize = 12,
			TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Size = UDim2.new(1, 0, 0, 15),
			Position = UDim2.new(0, 0, 0, 65),
			Parent = box,
		})
	end
	
	return box
end

function UIComponents:CreateProgressBar(parent, label, value, max, position)
	local container = UIUtils:CreateInstance("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -32, 0, 50),
		Position = position,
		Parent = parent,
	})
	
	local labelText = UIUtils:CreateInstance("TextLabel", {
		Text = label,
		TextSize = 13,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, 0, 0, 15),
		Parent = container,
	})
	
	local barBg = UIUtils:CreateInstance("Frame", {
		BackgroundColor3 = CONFIG.THEME.CARD_BG,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 0, 18),
		Parent = container,
	})
	UIUtils:AddCorner(barBg, 4)
	
	local barFill = UIUtils:CreateInstance("Frame", {
		BackgroundColor3 = CONFIG.THEME.PRIMARY,
		BorderSizePixel = 0,
		Size = UDim2.new(math.min(value / max, 1), 0, 1, 0),
		Parent = barBg,
	})
	UIUtils:AddCorner(barFill, 4)
	
	local percentage = UIUtils:CreateInstance("TextLabel", {
		Text = string.format("%.0f%%", (value / max) * 100),
		TextSize = 11,
		TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, 0, 0, 15),
		Position = UDim2.new(0, 0, 0, 30),
		Parent = container,
	})
	
	return container
end

-- ============================================
-- MAIN UI SCREENS
-- ============================================
local Screens = {}

function Screens:CreateDashboard()
	local screen = UIUtils:CreateInstance("Frame", {
		Name = "Dashboard",
		BackgroundColor3 = CONFIG.THEME.DARK_BG,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -50),
		Parent = self.ScreenContainer,
	})
	
	local scrolling = Instance.new("UIListLayout")
	scrolling.Padding = UDim.new(0, 16)
	scrolling.SortOrder = Enum.SortOrder.LayoutOrder
	scrolling.FillDirection = Enum.FillDirection.Vertical
	scrolling.Parent = screen
	
	-- Header
	local header = UIUtils:CreateInstance("TextLabel", {
		Name = "Header",
		Text = "💰 Мой Баланс",
		TextSize = 24,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, -32, 0, 40),
		Position = UDim2.new(0, 16, 0, 16),
		Parent = screen,
		LayoutOrder = 1,
	})
	
	-- Balance Card
	local balanceCard = UIComponents:CreateCard(screen, "Balance", UDim2.new(1, -32, 0, 140), UDim2.new(0, 16, 0, 65))
	balanceCard.LayoutOrder = 2
	balanceCard.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
	
	local balanceTitle = UIUtils:CreateInstance("TextLabel", {
		Text = "Total Balance",
		TextSize = 14,
		TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, 0, 0, 20),
		Parent = balanceCard,
	})
	
	local balanceValue = UIUtils:CreateInstance("TextLabel", {
		Text = string.format("$%.2f", AppState.totalBalance),
		TextSize = 40,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.new(0, 0, 0, 30),
		Parent = balanceCard,
	})
	
	-- Stats Row
	local statsContainer = UIUtils:CreateInstance("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -32, 0, 140),
		Position = UDim2.new(0, 16, 0, 0),
		Parent = screen,
		LayoutOrder = 3,
	})
	
	local statsLayout = Instance.new("UIGridLayout")
	statsLayout.CellSize = UDim2.new(0.5, -8, 0, 140)
	statsLayout.CellPadding = UDim2.new(0, 16, 0, 0)
	statsLayout.FillDirection = Enum.FillDirection.Horizontal
	statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	statsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	statsLayout.Parent = statsContainer
	
	UIComponents:CreateStatBox(statsContainer, "Это месяц", string.format("$%.2f", AppState.monthlyExpenses), "потрачено", CONFIG.THEME.ERROR, nil, UDim2.new(0, 0, 0, 0))
	UIComponents:CreateStatBox(statsContainer, "Траты", "4", "операции", CONFIG.THEME.WARNING, nil, UDim2.new(0, 0, 0, 0))
	
	-- Recent Expenses
	local expensesTitle = UIUtils:CreateInstance("TextLabel", {
		Text = "📋 Последние операции",
		TextSize = 18,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, -32, 0, 30),
		Position = UDim2.new(0, 16, 0, 0),
		Parent = screen,
		LayoutOrder = 4,
	})
	
	-- Expenses List
	for i, expense in ipairs(AppState.expenses) do
		local expenseCard = UIComponents:CreateCard(screen, "Expense" .. i, UDim2.new(1, -32, 0, 70), UDim2.new(0, 16, 0, 0))
		expenseCard.LayoutOrder = 4 + i
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Parent = expenseCard
		
		local icon = UIUtils:CreateInstance("TextLabel", {
			Text = expense.icon,
			TextSize = 24,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 40, 1, 0),
			Parent = expenseCard,
			LayoutOrder = 1,
		})
		
		local infoContainer = UIUtils:CreateInstance("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -60, 1, 0),
			Parent = expenseCard,
			LayoutOrder = 2,
		})
		
		local name = UIUtils:CreateInstance("TextLabel", {
			Text = expense.name,
			TextSize = 14,
			TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(1, 0, 0, 20),
			Parent = infoContainer,
		})
		
		local category = UIUtils:CreateInstance("TextLabel", {
			Text = expense.category .. " • " .. expense.date,
			TextSize = 11,
			TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 22),
			Parent = infoContainer,
		})
		
		local amount = UIUtils:CreateInstance("TextLabel", {
			Text = "-$" .. string.format("%.2f", expense.amount),
			TextSize = 16,
			TextColor3 = CONFIG.THEME.ERROR,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(0, 80, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = expenseCard,
			LayoutOrder = 3,
		})
	end
	
	-- Action Button
	UIComponents:CreateButton(screen, "➕ Добавить расход", UDim2.new(1, -32, 0, 50), UDim2.new(0, 16, 0, 0), CONFIG.THEME.SUCCESS, function()
		AppState.currentPage = "add_expense"
		self:SwitchScreen("add_expense")
	end)
	
	local lastButton = UIUtils:CreateInstance("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 1),
		Parent = screen,
		LayoutOrder = 999,
	})
	
	return screen
end

function Screens:CreateAddExpense()
	local screen = UIUtils:CreateInstance("Frame", {
		Name = "AddExpense",
		BackgroundColor3 = CONFIG.THEME.DARK_BG,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -50),
		Parent = self.ScreenContainer,
	})
	
	local scrolling = Instance.new("UIListLayout")
	scrolling.Padding = UDim.new(0, 16)
	scrolling.SortOrder = Enum.SortOrder.LayoutOrder
	scrolling.FillDirection = Enum.FillDirection.Vertical
	scrolling.Parent = screen
	
	-- Header
	local header = UIUtils:CreateInstance("TextLabel", {
		Text = "➕ Добавить расход",
		TextSize = 24,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, -32, 0, 40),
		Position = UDim2.new(0, 16, 0, 16),
		Parent = screen,
		LayoutOrder = 1,
	})
	
	-- Input Fields
	local function CreateInputField(parent, placeholder, layoutOrder)
		local field = UIComponents:CreateCard(parent, placeholder, UDim2.new(1, -32, 0, 50), nil)
		field.LayoutOrder = layoutOrder
		field.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
		
		local input = UIUtils:CreateInstance("TextBox", {
			Name = "Input",
			PlaceholderText = placeholder,
			Text = "",
			TextSize = 16,
			TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
			PlaceholderColor3 = CONFIG.THEME.TEXT_SECONDARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Size = UDim2.new(1, 0, 1, 0),
			ClearTextOnFocus = false,
			Parent = field,
		})
		
		local padding = Instance.new("UIPadding")
		padding.PaddingLeft = CONFIG.PADDING
		padding.PaddingRight = CONFIG.PADDING
		padding.Parent = input
		
		return field
	end
	
	CreateInputField(screen, "Название расхода", 2)
	CreateInputField(screen, "Сумма ($)", 3)
	CreateInputField(screen, "Категория", 4)
	CreateInputField(screen, "Дата", 5)
	
	-- Buttons Row
	local buttonsContainer = UIUtils:CreateInstance("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -32, 0, 60),
		Position = UDim2.new(0, 16, 0, 0),
		Parent = screen,
		LayoutOrder = 6,
	})
	
	local buttonsLayout = Instance.new("UIGridLayout")
	buttonsLayout.CellSize = UDim2.new(0.5, -8, 0, 60)
	buttonsLayout.CellPadding = UDim2.new(0, 16, 0, 0)
	buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonsLayout.Parent = buttonsContainer
	
	UIComponents:CreateButton(buttonsContainer, "✅ Сохранить", UDim2.new(1, 0, 1, 0), nil, CONFIG.THEME.SUCCESS, function()
		print("Расход добавлен!")
		AppState.currentPage = "dashboard"
		Screens:SwitchScreen("dashboard")
	end)
	
	UIComponents:CreateButton(buttonsContainer, "❌ Отмена", UDim2.new(1, 0, 1, 0), nil, CONFIG.THEME.ERROR, function()
		AppState.currentPage = "dashboard"
		Screens:SwitchScreen("dashboard")
	end)
	
	return screen
end

function Screens:CreateBudget()
	local screen = UIUtils:CreateInstance("Frame", {
		Name = "Budget",
		BackgroundColor3 = CONFIG.THEME.DARK_BG,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -50),
		Parent = self.ScreenContainer,
	})
	
	local scrolling = Instance.new("UIListLayout")
	scrolling.Padding = UDim.new(0, 16)
	scrolling.SortOrder = Enum.SortOrder.LayoutOrder
	scrolling.FillDirection = Enum.FillDirection.Vertical
	scrolling.Parent = screen
	
	-- Header
	local header = UIUtils:CreateInstance("TextLabel", {
		Text = "💳 Бюджеты",
		TextSize = 24,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, -32, 0, 40),
		Position = UDim2.new(0, 16, 0, 16),
		Parent = screen,
		LayoutOrder = 1,
	})
	
	-- Budget Items
	for i, budget in ipairs(AppState.budgets) do
		local budgetCard = UIComponents:CreateCard(screen, budget.category, UDim2.new(1, -32, 0, 120), nil)
		budgetCard.LayoutOrder = 1 + i
		
		local title = UIUtils:CreateInstance("TextLabel", {
			Text = budget.category,
			TextSize = 16,
			TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(1, 0, 0, 20),
			Parent = budgetCard,
		})
		
		UIComponents:CreateProgressBar(budgetCard, "", budget.spent, budget.limit, UDim2.new(0, 0, 0, 25))
		
		local info = UIUtils:CreateInstance("TextLabel", {
			Text = string.format("$%.2f / $%.2f потрачено", budget.spent, budget.limit),
			TextSize = 12,
			TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Size = UDim2.new(1, 0, 0, 15),
			Position = UDim2.new(0, 0, 0, 85),
			Parent = budgetCard,
		})
	end
	
	UIComponents:CreateButton(screen, "⚙️ Редактировать", UDim2.new(1, -32, 0, 50), UDim2.new(0, 16, 0, 0), CONFIG.THEME.SECONDARY, function()
		print("Редактирование бюджета...")
	end)
	
	return screen
end

function Screens:CreateAnalytics()
	local screen = UIUtils:CreateInstance("Frame", {
		Name = "Analytics",
		BackgroundColor3 = CONFIG.THEME.DARK_BG,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -50),
		Parent = self.ScreenContainer,
	})
	
	local scrolling = Instance.new("UIListLayout")
	scrolling.Padding = UDim.new(0, 16)
	scrolling.SortOrder = Enum.SortOrder.LayoutOrder
	scrolling.FillDirection = Enum.FillDirection.Vertical
	scrolling.Parent = screen
	
	-- Header
	local header = UIUtils:CreateInstance("TextLabel", {
		Text = "📊 Аналитика",
		TextSize = 24,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, -32, 0, 40),
		Position = UDim2.new(0, 16, 0, 16),
		Parent = screen,
		LayoutOrder = 1,
	})
	
	-- Category Breakdown
	local categories = {
		{name = "Еда", amount = 80.50, percent = 29},
		{name = "Транспорт", amount = 25.50, percent = 9},
		{name = "Развлечение", amount = 50.00, percent = 18},
		{name = "Прочее", amount = 120.00, percent = 44},
	}
	
	for i, cat in ipairs(categories) do
		local item = UIComponents:CreateCard(screen, cat.name, UDim2.new(1, -32, 0, 70), nil)
		item.LayoutOrder = 1 + i
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Parent = item
		
		local name = UIUtils:CreateInstance("TextLabel", {
			Text = cat.name,
			TextSize = 14,
			TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(0, 100, 1, 0),
			Parent = item,
			LayoutOrder = 1,
		})
		
		local amount = UIUtils:CreateInstance("TextLabel", {
			Text = string.format("$%.2f", cat.amount),
			TextSize = 14,
			TextColor3 = CONFIG.THEME.PRIMARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(0, 80, 1, 0),
			Parent = item,
			LayoutOrder = 2,
		})
		
		local percent = UIUtils:CreateInstance("TextLabel", {
			Text = cat.percent .. "%",
			TextSize = 14,
			TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Size = UDim2.new(0, 50, 1, 0),
			Parent = item,
			LayoutOrder = 3,
		})
	end
	
	-- Recommendations
	local recCard = UIComponents:CreateCard(screen, "Рекомендации", UDim2.new(1, -32, 0, 100), nil)
	recCard.LayoutOrder = 100
	
	local recTitle = UIUtils:CreateInstance("TextLabel", {
		Text = "💡 Рекомендации",
		TextSize = 14,
		TextColor3 = CONFIG.THEME.PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 20),
		Parent = recCard,
	})
	
	local recText = UIUtils:CreateInstance("TextLabel", {
		Text = "Прочие расходы превышают бюджет на 40%. Рекомендуется снизить траты в этой категории.",
		TextSize = 12,
		TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 1, -25),
		Position = UDim2.new(0, 0, 0, 25),
		Parent = recCard,
	})
	
	return screen
end

function Screens:CreateSettings()
	local screen = UIUtils:CreateInstance("Frame", {
		Name = "Settings",
		BackgroundColor3 = CONFIG.THEME.DARK_BG,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -50),
		Parent = self.ScreenContainer,
	})
	
	local scrolling = Instance.new("UIListLayout")
	scrolling.Padding = UDim.new(0, 16)
	scrolling.SortOrder = Enum.SortOrder.LayoutOrder
	scrolling.FillDirection = Enum.FillDirection.Vertical
	scrolling.Parent = screen
	
	-- Header
	local header = UIUtils:CreateInstance("TextLabel", {
		Text = "⚙️ Настройки",
		TextSize = 24,
		TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, -32, 0, 40),
		Position = UDim2.new(0, 16, 0, 16),
		Parent = screen,
		LayoutOrder = 1,
	})
	
	-- Settings Options
	local settings = {
		{icon = "👤", title = "Профиль", desc = "Управлять профилем"},
		{icon = "🔔", title = "Уведомления", desc = "Напоминания о расходах"},
		{icon = "💾", title = "Экспорт", desc = "Сохранить данные"},
		{icon = "🔄", title = "Синхронизация", desc = "Синхронизировать облако"},
		{icon = "ℹ️", title = "О приложении", desc = "Версия и информация"},
	}
	
	for i, setting in ipairs(settings) do
		local item = UIComponents:CreateCard(screen, setting.title, UDim2.new(1, -32, 0, 70), nil)
		item.LayoutOrder = 1 + i
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 12)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Parent = item
		
		local icon = UIUtils:CreateInstance("TextLabel", {
			Text = setting.icon,
			TextSize = 20,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 30, 1, 0),
			Parent = item,
			LayoutOrder = 1,
		})
		
		local textContainer = UIUtils:CreateInstance("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -60, 1, 0),
			Parent = item,
			LayoutOrder = 2,
		})
		
		local title = UIUtils:CreateInstance("TextLabel", {
			Text = setting.title,
			TextSize = 14,
			TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(1, 0, 0, 20),
			Parent = textContainer,
		})
		
		local desc = UIUtils:CreateInstance("TextLabel", {
			Text = setting.desc,
			TextSize = 11,
			TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 22),
			Parent = textContainer,
		})
		
		local arrow = UIUtils:CreateInstance("TextLabel", {
			Text = "→",
			TextSize = 16,
			TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 30, 1, 0),
			Parent = item,
			LayoutOrder = 3,
		})
	end
	
	-- Logout Button
	UIComponents:CreateButton(screen, "🚪 Выход", UDim2.new(1, -32, 0, 50), UDim2.new(0, 16, 0, 0), CONFIG.THEME.ERROR, function()
		print("Выход из приложения...")
	end)
	
	return screen
end

-- ============================================
-- MAIN GUI INITIALIZATION
-- ============================================
function Screens:Init()
	self.ScreenContainer = UIUtils:CreateInstance("Frame", {
		Name = "ExpensiWApp",
		BackgroundColor3 = CONFIG.THEME.DARK_BG,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 400, 0, 600),
		Position = UDim2.new(0.5, -200, 0.5, -300),
		Parent = playerGui,
	})
	
	UIUtils:AddCorner(self.ScreenContainer, 16)
	
	-- Screens
	self.screens = {
		dashboard = self:CreateDashboard(),
		add_expense = self:CreateAddExpense(),
		budget = self:CreateBudget(),
		analytics = self:CreateAnalytics(),
		settings = self:CreateSettings(),
	}
	
	-- Navigation Bar
	local navBar = UIUtils:CreateInstance("Frame", {
		Name = "NavBar",
		BackgroundColor3 = CONFIG.THEME.CARD_BG,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 50),
		Position = UDim2.new(0, 0, 1, -50),
		Parent = self.ScreenContainer,
	})
	
	local navLayout = Instance.new("UIGridLayout")
	navLayout.CellSize = UDim2.new(0.2, 0, 1, 0)
	navLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	navLayout.FillDirection = Enum.FillDirection.Horizontal
	navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	navLayout.Parent = navBar
	
	local navItems = {
		{icon = "📊", page = "dashboard", name = "Главная"},
		{icon = "📋", page = "add_expense", name = "Добавить"},
		{icon = "💳", page = "budget", name = "Бюджет"},
		{icon = "📈", page = "analytics", name = "Аналитика"},
		{icon = "⚙️", page = "settings", name = "Настройки"},
	}
	
	for i, item in ipairs(navItems) do
		local navBtn = UIUtils:CreateInstance("TextButton", {
			Name = "Nav" .. item.page,
			Text = item.icon .. "\n" .. item.name,
			TextSize = 10,
			TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(0.2, 0, 1, 0),
			Parent = navBar,
		})
		
		navBtn.Activated:Connect(function()
			AppState.currentPage = item.page
			self:SwitchScreen(item.page)
			
			for _, btn in pairs(navBar:GetChildren()) do
				if btn:IsA("TextButton") then
					btn.BackgroundTransparency = 1
				end
			end
			navBtn.BackgroundTransparency = 0.8
		end)
	end
	
	-- Show initial screen
	self:SwitchScreen("dashboard")
end

function Screens:SwitchScreen(screenName)
	for name, screen in pairs(self.screens) do
		screen.Visible = (name == screenName)
	end
	UIUtils:AnimateIn(self.screens[screenName])
end

-- ============================================
-- START APPLICATION
-- ============================================
Screens:Init()

print("✅ Expensiw UI loaded successfully!")
