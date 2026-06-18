"""
TelcoChisel — Boot Asset Generator
Run from repo root:  python3 builder/boot/generate-assets.py

Generates (relative to repo root):
  builder/boot/plymouth/glow.png              – radial cyan glow for Plymouth
  builder/boot/plymouth/progress_dot_on.png   – lit progress dot (Plymouth)
  builder/boot/plymouth/progress_dot_off.png  – dim progress dot (Plymouth)
  builder/boot/grub_background.png            – GRUB splash (1920×1080)
  builder/boot/wallpaper.png                  – desktop wallpaper (1920×1080)

Requires: Pillow  (pip install Pillow)
"""

import os
import math
from PIL import Image, ImageDraw

# ── Paths ────────────────────────────────────────────────────────────────────
here      = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.dirname(os.path.dirname(here))
logo_path = os.path.join(repo_root, "builder", "calamares", "branding", "telcosec", "logo.png")
boot_dir  = os.path.join(repo_root, "builder", "boot")
ply_dir   = os.path.join(boot_dir, "plymouth")
os.makedirs(ply_dir, exist_ok=True)

# ── Brand palette ────────────────────────────────────────────────────────────
BG         = (12,  15,  22,  255)   # #0C0F16 obsidian background
BG_DEEP    = (8,   10,  18,  255)   # #080A12 gradient bottom
CYAN       = (0,   212, 230, 255)   # #00D4E6 brand cyan
CYAN_DIM   = (0,   212, 230,  80)   # translucent cyan
WHITE      = (255, 255, 255, 255)
WHITE_DIM  = (200, 210, 220, 160)   # soft white for subtitle
DARK_DOT   = (25,  35,  55,  255)   # off-state dot colour

# ── Resampling ───────────────────────────────────────────────────────────────
try:
    LANCZOS = Image.Resampling.LANCZOS
except AttributeError:
    LANCZOS = Image.LANCZOS


# ── Font loader ──────────────────────────────────────────────────────────────
def load_font(size):
    """Try Ubuntu/DejaVu truetype fonts; fall back to PIL bitmap default."""
    from PIL import ImageFont
    candidates = [
        "/usr/share/fonts/truetype/ubuntu/Ubuntu-B.ttf",
        "/usr/share/fonts/truetype/ubuntu/Ubuntu-R.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/calibri.ttf",
        "C:/Windows/Fonts/arial.ttf",
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    try:
        return ImageFont.load_default(size=size)
    except TypeError:
        return ImageFont.load_default()


def text_size(draw, text, font):
    """Return (width, height) for text."""
    try:
        bb = draw.textbbox((0, 0), text, font=font)
        return bb[2] - bb[0], bb[3] - bb[1]
    except AttributeError:
        return draw.textsize(text, font=font)


# ── 1. Plymouth glow.png ─────────────────────────────────────────────────────
print("Generating Plymouth glow.png …")
SIZE = 512
glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
pix  = glow.load()
cx = cy = SIZE // 2
for y in range(SIZE):
    for x in range(SIZE):
        dist = math.hypot(x - cx, y - cy)
        if dist < cx:
            t     = 1.0 - dist / cx
            alpha = int(120 * t * t)          # quadratic falloff, peak 120/255
            r, g, b = 0, 212, 230             # brand cyan
            pix[x, y] = (r, g, b, alpha)
glow.save(os.path.join(ply_dir, "glow.png"))
print("  → glow.png")


# ── 2. Progress dot PNGs ─────────────────────────────────────────────────────
print("Generating Plymouth progress dots …")
DOT = 16   # pixel diameter

def make_dot(colour, glow_colour=None):
    img  = Image.new("RGBA", (DOT, DOT), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse((1, 1, DOT - 2, DOT - 2), fill=colour)
    if glow_colour:
        # soft outer ring
        draw.ellipse((0, 0, DOT - 1, DOT - 1), outline=glow_colour, width=1)
    return img

dot_on  = make_dot(CYAN,     glow_colour=(120, 240, 255, 200))
dot_off = make_dot(DARK_DOT)
dot_on.save(os.path.join(ply_dir, "progress_dot_on.png"))
dot_off.save(os.path.join(ply_dir, "progress_dot_off.png"))
print("  → progress_dot_on.png, progress_dot_off.png")


# ── Shared: load + mask logo ─────────────────────────────────────────────────
if not os.path.exists(logo_path):
    print(f"ERROR: logo not found at {logo_path}")
    raise SystemExit(1)

logo_orig = Image.open(logo_path).convert("RGBA")

# Circular alpha mask to clean square corners from the source PNG
mask = Image.new("L", logo_orig.size, 0)
ImageDraw.Draw(mask).ellipse((0, 0, logo_orig.width, logo_orig.height), fill=255)
logo_orig.putalpha(mask)


# ── Helper: radial glow on canvas ────────────────────────────────────────────
def draw_radial_glow(canvas, cx, cy, radius, r, g, b, peak_alpha):
    """Paint a soft radial glow directly onto an RGBA canvas."""
    pix = canvas.load()
    W, H = canvas.size
    r0   = max(0, int(cx - radius))
    r1   = min(W, int(cx + radius))
    c0   = max(0, int(cy - radius))
    c1   = min(H, int(cy + radius))
    for py in range(c0, c1):
        for px in range(r0, r1):
            dist = math.hypot(px - cx, py - cy)
            if dist >= radius:
                continue
            t   = (1.0 - dist / radius) ** 2
            a   = t * peak_alpha / 255.0
            old = pix[px, py]
            pix[px, py] = (
                int(old[0] * (1 - a) + r * a),
                int(old[1] * (1 - a) + g * a),
                int(old[2] * (1 - a) + b * a),
                255,
            )


# ── Helper: signal wave rings ─────────────────────────────────────────────────
def draw_signal_rings(draw, cx, cy, n_rings, base_r, step, colour, width=1):
    """Draw n concentric thin rings (signal waves)."""
    for i in range(n_rings):
        r = base_r + i * step
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=colour, width=width)


# ── Helper: subtle hex grid ───────────────────────────────────────────────────
def draw_hex_grid(canvas, cell_size=64, colour=(0, 212, 230, 8)):
    """Overlay a very faint hexagonal dot grid."""
    draw = ImageDraw.Draw(canvas)
    W, H = canvas.size
    h    = cell_size * math.sqrt(3) / 2
    cols = int(W / cell_size) + 2
    rows = int(H / h) + 2
    for row in range(rows):
        for col in range(cols):
            x = col * cell_size + (cell_size / 2 if row % 2 else 0) - cell_size
            y = row * h - h
            draw.ellipse((x - 1.5, y - 1.5, x + 1.5, y + 1.5), fill=colour)


# ── 3. GRUB background (1920×1080) ───────────────────────────────────────────
print("Generating GRUB background (1920×1080) …")
W, H = 1920, 1080
bg   = Image.new("RGBA", (W, H), BG)

# Soft background glow centred on screen
draw_radial_glow(bg, W // 2, H // 2, 600, 0, 212, 230, 28)

# Signal rings (very subtle)
ring_draw = ImageDraw.Draw(bg)
draw_signal_rings(ring_draw, W // 2, H // 2, 5, 280, 90,
                  colour=(0, 212, 230, 18), width=1)

# Logo (450 × 450)
logo_g = logo_orig.resize((450, 450), LANCZOS)
bg.paste(logo_g, ((W - 450) // 2, (H - 450) // 2), logo_g)

bg.convert("RGB").save(os.path.join(boot_dir, "grub_background.png"))
print("  → grub_background.png")


# ── 4. Desktop wallpaper (1920×1080) ─────────────────────────────────────────
print("Generating desktop wallpaper (1920×1080) …")
W, H = 1920, 1080

# Gradient background (top BG, bottom BG_DEEP)
wall = Image.new("RGBA", (W, H), BG)
for y in range(H):
    t = y / H
    r = int(BG[0] * (1 - t) + BG_DEEP[0] * t)
    g = int(BG[1] * (1 - t) + BG_DEEP[1] * t)
    b = int(BG[2] * (1 - t) + BG_DEEP[2] * t)
    for x in range(W):
        wall.putpixel((x, y), (r, g, b, 255))

# Hex dot grid overlay
draw_hex_grid(wall, cell_size=72, colour=(0, 212, 230, 9))

# Central radial glow
LOGO_SIZE   = 420
LOGO_CX, LOGO_CY = W // 2, int(H * 0.42)
draw_radial_glow(wall, LOGO_CX, LOGO_CY, 500, 0, 212, 230, 40)

# Signal wave rings radiating from logo centre
wd = ImageDraw.Draw(wall)
draw_signal_rings(wd, LOGO_CX, LOGO_CY, 6, 280, 100,
                  colour=(0, 212, 230, 22), width=1)
# Outermost two rings slightly brighter
draw_signal_rings(wd, LOGO_CX, LOGO_CY, 2, 680, 110,
                  colour=(0, 212, 230, 14), width=1)

# Logo
logo_w = logo_orig.resize((LOGO_SIZE, LOGO_SIZE), LANCZOS)
wall.paste(logo_w, (LOGO_CX - LOGO_SIZE // 2, LOGO_CY - LOGO_SIZE // 2), logo_w)

# ── Typography ────────────────────────────────────────────────────────────────
tw = ImageDraw.Draw(wall)

font_title    = load_font(52)
font_subtitle = load_font(22)
font_small    = load_font(14)

# "TelcoChisel" — brand cyan, centred below logo
title_text = "TELCOSEC  CHISEL"
tw_w, tw_h = text_size(tw, title_text, font_title)
title_y    = LOGO_CY + LOGO_SIZE // 2 + 44
tw.text(((W - tw_w) // 2, title_y), title_text,
        fill=(0, 212, 230, 240), font=font_title)

# Tagline — muted white
tagline      = "Telecom Security Research Platform"
tl_w, tl_h  = text_size(tw, tagline, font_subtitle)
tagline_y    = title_y + tw_h + 14
tw.text(((W - tl_w) // 2, tagline_y), tagline,
        fill=(180, 200, 210, 160), font=font_subtitle)

# Bottom separator line
line_y = H - 48
tw.line([(80, line_y), (W - 80, line_y)], fill=(0, 212, 230, 70), width=1)

# URL — bottom left
url_text   = "telco-sec.com"
url_w, _   = text_size(tw, url_text, font_small)
tw.text((88, line_y + 10), url_text, fill=(0, 212, 230, 120), font=font_small)

# Year — bottom right
yr_text  = "2026"
yr_w, _  = text_size(tw, yr_text, font_small)
tw.text((W - 88 - yr_w, line_y + 10), yr_text,
        fill=(100, 120, 140, 100), font=font_small)

wall.convert("RGB").save(os.path.join(boot_dir, "wallpaper.png"))
print("  → wallpaper.png")

print("\nAll assets generated successfully.")
