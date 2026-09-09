import colorsys, os, textwrap
T = os.path.expanduser("~/.config/omarchy/themes")

def h2r(h): h=h.lstrip('#'); return tuple(int(h[i:i+2],16)/255 for i in (0,2,4))
def r2h(r): return '#%02x%02x%02x' % tuple(max(0,min(255,round(c*255))) for c in r)
def lum(h, f):  # scale lightness in HLS
    r,g,b = h2r(h); hh,l,s = colorsys.rgb_to_hls(r,g,b)
    return r2h(colorsys.hls_to_rgb(hh, max(0,min(1,l*f)), s))
def mix(a,b,t):
    ra,rb = h2r(a),h2r(b); return r2h(tuple(x+(y-x)*t for x,y in zip(ra,rb)))

# slug: (bg, fg, accent, selection, muted, red, orange, yellow, green, cyan, blue, magenta, brown, icons)
THEMES = {
 "asia-neon":            ("#14111f","#e6e0f5","#a67bff","#3a2f5c","#6f6790","#ff6b8a","#ff9f5a","#ffd166","#6ee7a8","#5cd8ff","#5a8cff","#d67bff","#8a6f9a","Yaru-purple"),
 "asia-lagoon":          ("#0e1b22","#dcecf0","#3fc1c9","#1f4048","#5f7f86","#ef7a70","#f2a65a","#f0d078","#8ccf6b","#4fd6d3","#4aa3df","#c98ad1","#a08a6a","Yaru-prussiangreen"),
 "asia-sunset":          ("#1a1216","#f6e6dc","#ff8a5c","#4a2c33","#8a6c6c","#ff6b6b","#ff9950","#ffc857","#9ccf7a","#7fd0d8","#7fa0e8","#e88bc0","#a07060","Yaru-red"),
 "asia-jungle":          ("#111a12","#e3ecdd","#7fbf5a","#2b402a","#6f8468","#e06c60","#e39a52","#e6c86b","#8fd46a","#6fc9b6","#6fa3d6","#c48bc7","#8f7a55","Yaru-olive"),
 "asia-city":            ("#15181b","#dfe4e8","#7aa2c8","#2f3a44","#6c777f","#e2726f","#e09a5c","#e3c76d","#8fc57a","#72c4c9","#76a7d9","#b892c8","#937d66","Yaru-blue"),
 "costa-rica-jungle":    ("#121a0f","#e6ebdc","#8fbf47","#2e4223","#718162","#d9705f","#e19c4d","#dcc862","#9bd05a","#6cc4a7","#6ea0cc","#bd8cc4","#9a7f4c","Yaru-olive"),
 "costa-rica-sunset":    ("#1d1220","#f8e9dc","#f2a261","#4b2b45","#8c6f80","#f26b6b","#f59a58","#f7c96a","#a4cf7c","#82cfd6","#8f9fe6","#d98bc4","#a5766a","Yaru-magenta"),
 "copenhagen":           ("#1a1613","#efe6da","#d8963a","#46372a","#80735f","#d6544a","#e08a3a","#e8bf52","#93b86a","#6dbfc8","#4c8fce","#c085b6","#93632e","Yaru-yellow"),
 "fireplace":            ("#140806","#fbedca","#f07a2a","#4a1d10","#8a5c48","#e8452a","#f5842e","#f7b955","#b9b86a","#d9b27c","#d07a4a","#e08060","#7a3a1e","Yaru-red"),
 "alps-winter":          ("#0f1620","#e8eef7","#6fa8dc","#2b3d55","#6e8199","#e07070","#e39b62","#e9cf7a","#8fca8a","#7fd3e6","#6b9fdf","#b797d9","#958559","Yaru-blue"),
 "toeff":                ("#121314","#e6e6e8","#b8b8bc","#35373a","#737578","#d66c6c","#d69760","#d9c47a","#a2b36b","#86bfc4","#86a3c8","#b596bf","#8c8266","Yaru"),
 "misc":                 ("#131722","#e8e6e2","#5b8fd6","#2d3a58","#72788a","#dc6e62","#dd9a58","#e2c46e","#93bd78","#74c3cc","#6f9be0","#c08cc4","#ad8f64","Yaru-blue"),
 "highlights-lakes":     ("#101816","#e2ebe6","#5aa9c4","#263f3a","#6a8079","#e0716a","#e39c5a","#e2c86d","#8ec86f","#66c9c4","#6b9fd4","#bb8fc7","#958757","Yaru-prussiangreen"),
 "highlights-sunset":    ("#1a1510","#f3e9d8","#e0a55a","#47382a","#857560","#e06a5a","#ea9a4a","#f0c66a","#aac47a","#86c7c3","#7f9fd0","#cf90b0","#9a7a55","Yaru-yellow"),
 "boezingenberg":        ("#12181f","#e6edf4","#7297bb","#2c3c4c","#6f7f8f","#dd7373","#dd9c68","#e2cc80","#92c48c","#7ccbd8","#7aa3d3","#b498d1","#858071","Yaru-blue"),
 "eiger-moench-jungfrau":("#0d1a2a","#eef3f8","#539ad6","#234466","#6c86a0","#e57373","#e8a065","#efd27e","#8fcf94","#7fd8ea","#5fa3e6","#b79ddf","#8f805a","Yaru-blue"),
 "horizon":              ("#14161b","#e4e8ee","#98b5d9","#303744","#737a86","#e07474","#e39d66","#e6cb7c","#98c48a","#7ccad4","#7ea6dc","#b79bd3","#8c7f6c","Yaru-blue"),
 "lauenensee":           ("#15160f","#ebe9d9","#b8a24a","#3d3c26","#7d7c61","#d8705a","#dd9a48","#e0c25a","#9fb85a","#78bfb0","#7ea0c4","#bb90b0","#948b64","Yaru-olive"),
 "les-pres-dorvin":      ("#161a21","#eceef2","#8fa3c4","#333b4a","#7d8391","#e07a7a","#e2a06c","#e6cf88","#9cc79a","#8ccfdb","#86aadb","#b9a0d6","#8c8478","Yaru-blue"),
 "lido-vira-ticino":     ("#171716","#ede9e0","#c9a46a","#3d3a33","#7f8186","#dd7566","#e09c58","#e6c66e","#9dbf78","#7fc4cc","#7a97b8","#c092b8","#a08d73","Yaru-wartybrown"),
 "pabukid-sa-indahag":   ("#101915","#e2ece7","#62b7c9","#274038","#6f7f78","#e07068","#e39c5c","#e3c86f","#8fc978","#6ccdd0","#64a0d0","#bb90c8","#908f6a","Yaru-sage"),
 "ticino":               ("#12171a","#e4eaec","#6fa3c4","#2a3a44","#6f7f86","#df7070","#e29d62","#e4cb78","#a1c464","#74c8cc","#6e9fd0","#b896c8","#8f8266","Yaru-prussiangreen"),
}

for slug,(bg,fg,acc,sel,mut,red,orange,yellow,green,cyan,blue,magenta,brown,icons) in THEMES.items():
    d = f"{T}/pics-{slug}"
    toml = f"""# pics-{slug} — generated from personal desktop photos
mode = "dark"

accent = "{acc}"
selection = "{sel}"
muted = "{mut}"

background = "{bg}"
dark_background = "{lum(bg,0.75)}"
darker_background = "{lum(bg,0.55)}"
lighter_background = "{mix(bg,fg,0.10)}"

foreground = "{fg}"
dark_foreground = "{mix(fg,bg,0.28)}"
light_foreground = "{mix(fg,'#ffffff',0.25)}"
bright_foreground = "{mix(fg,'#ffffff',0.45)}"

red = "{red}"
yellow = "{yellow}"
orange = "{orange}"
green = "{green}"
cyan = "{cyan}"
blue = "{blue}"
magenta = "{magenta}"
brown = "{brown}"

bright_red = "{lum(red,1.12)}"
bright_yellow = "{lum(yellow,1.10)}"
bright_green = "{lum(green,1.12)}"
bright_cyan = "{lum(cyan,1.10)}"
bright_blue = "{lum(blue,1.12)}"
bright_magenta = "{lum(magenta,1.10)}"
"""
    open(f"{d}/colors.toml","w").write(toml)
    open(f"{d}/icons.theme","w").write(icons+"\n")
    print(slug, "ok")
