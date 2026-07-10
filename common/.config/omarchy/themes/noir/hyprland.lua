-- Noir Hyprland theme include.
local activeBorderColor = {
	colors = { "rgb(080706)", "rgb(5a6674)", "rgb(96423c)", "rgb(080706)" },
	angle = 135,
}
local inactiveBorderColor = {
	colors = { "rgba(6f665f99)", "rgba(2d251f55)", "rgba(080706cc)" },
	angle = 135,
}
local activeShadowColor = "rgba(000000aa)"
local inactiveShadowColor = "rgba(00000055)"
local browserClass = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|zen|[fF]irefox)"

hl.config({
	general = {
		col = {
			active_border = activeBorderColor,
			inactive_border = inactiveBorderColor,
		},
		border_size = 2,
		gaps_in = 7,
		gaps_out = 22,
	},
	group = {
		col = {
			border_active = activeBorderColor,
			border_inactive = inactiveBorderColor,
		},
	},
	decoration = {
		rounding = 0,
		dim_inactive = true,
		dim_strength = 0.20,
		--active_opacity = 1.0,
		inactive_opacity = 0.93,
		blur = {
			enabled = true,
			size = 2,
			passes = 1,
			noise = 0.08,
			contrast = 0.40,
			vibrancy = 0.1,
			vibrancy_darkness = 0.28,
		},
		shadow = {
			enabled = true,
			range = 20,
			render_power = 4,
			offset = "6 8",
			color = activeShadowColor,
			color_inactive = inactiveShadowColor,
		},
	},
	animations = {
		enabled = true,
	},
})

hl.window_rule({
	name = "noir-browser-no-dim",
	match = {
		class = browserClass,
	},
	no_dim = true,
})

hl.curve("noirCut", { type = "bezier", points = { { 0.18, 0.92 }, { 0.16, 1.0 } } })
hl.curve("noirDrift", { type = "bezier", points = { { 0.12, 0.72 }, { 0.24, 1.0 } } })

local function noirAnimation(leaf, speed, style, curve)
	local animation = {
		leaf = leaf,
		enabled = true,
		speed = speed,
		bezier = curve or "noirCut",
	}

	if style then
		animation.style = style
	end

	hl.animation(animation)
end

noirAnimation("windows", 6)
noirAnimation("windowsIn", 7, "popin 8%")
noirAnimation("windowsOut", 5, "popin 55%")
noirAnimation("border", 7)
noirAnimation("fade", 5)
noirAnimation("fadeIn", 5)
noirAnimation("fadeOut", 4)
noirAnimation("layers", 5)
noirAnimation("layersIn", 5, "fade")
noirAnimation("layersOut", 4, "fade")
noirAnimation("fadeLayersIn", 5)
noirAnimation("fadeLayersOut", 4)
noirAnimation("workspaces", 5, "slide", "noirDrift")
noirAnimation("specialWorkspace", 5, "slidevert", "noirDrift")
