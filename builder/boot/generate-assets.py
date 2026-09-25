"""
TelcoChisel — Boot Asset Generator
Run from repo root:  python3 builder/boot/generate-assets.py

Generates (relative to repo root):
  builder/boot/plymouth/glow.png              – radial cyan glow for Plymouth
  builder/boot/plymouth/progress_dot_on.png   – lit progress dot (Plymouth)
  builder/boot/plymouth/progress_dot_off.png  – dim progress dot (Plymouth)
  builder/boot/plymouth/password_field.png    – LUKS unlock text field (Plymouth)
  builder/boot/plymouth/password_dot.png      – LUKS unlock bullet dot (Plymouth)
  builder/boot/grub_background.png            – GRUB splash (1920×1080)
  builder/boot/wallpaper.jpg                  – desktop wallpaper (1920×1080)

Requires: Pillow  (pip install Pillow)
"""

import os
import sys
import math
from PIL import Image, ImageDraw

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass


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
def load_font(size, bold=False):
    """Try Ubuntu/DejaVu truetype fonts; fall back to PIL bitmap default."""
    from PIL import ImageFont
    if bold:
        candidates = [
            "/usr/share/fonts/truetype/ubuntu/Ubuntu-B.ttf",
            "/usr/share/fonts/truetype/ubuntu/Ubuntu-Bold.ttf",
            "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
            "C:/Windows/Fonts/segoeuib.ttf",
            "C:/Windows/Fonts/calibrib.ttf",
            "C:/Windows/Fonts/arialbd.ttf",
        ]
    else:
        candidates = [
            "/usr/share/fonts/truetype/ubuntu/Ubuntu-R.ttf",
            "/usr/share/fonts/truetype/ubuntu/Ubuntu-Regular.ttf",
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
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
print("Generating Plymouth glow.png ...")
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
print("  -> glow.png")


# ── 2. Progress dot PNGs ─────────────────────────────────────────────────────
print("Generating Plymouth progress dots ...")
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
print("  -> progress_dot_on.png, progress_dot_off.png")


# ── 2b. Password prompt assets (LUKS unlock dialogue, telcosec.script) ──────
print("Generating Plymouth password prompt assets ...")
FIELD_W, FIELD_H = 300, 40
field  = Image.new("RGBA", (FIELD_W, FIELD_H), (0, 0, 0, 0))
fdraw  = ImageDraw.Draw(field)
fdraw.rounded_rectangle(
    (0, 0, FIELD_W - 1, FIELD_H - 1),
    radius=FIELD_H // 2,
    fill=(16, 20, 30, 200),
    outline=(0, 212, 230, 160),
    width=2,
)
field.save(os.path.join(ply_dir, "password_field.png"))
print("  -> password_field.png")

DOT_SIZE = 14
pdot  = Image.new("RGBA", (DOT_SIZE, DOT_SIZE), (0, 0, 0, 0))
pdraw = ImageDraw.Draw(pdot)
pdraw.ellipse((1, 1, DOT_SIZE - 2, DOT_SIZE - 2), fill=(0, 212, 230, 255))
pdot.save(os.path.join(ply_dir, "password_dot.png"))
print("  -> password_dot.png")


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
def draw_hex_grid(canvas, cell_size=64, colour=(0, 212, 230, 8), exclude_box=None):
    """Overlay a very faint hexagonal dot grid with optional exclusion bounding box."""
    draw = ImageDraw.Draw(canvas)
    W, H = canvas.size
    h    = cell_size * math.sqrt(3) / 2
    cols = int(W / cell_size) + 2
    rows = int(H / h) + 2
    for row in range(rows):
        for col in range(cols):
            x = col * cell_size + (cell_size / 2 if row % 2 else 0) - cell_size
            y = row * h - h
            if exclude_box and (exclude_box[0] <= x <= exclude_box[2] and exclude_box[1] <= y <= exclude_box[3]):
                continue
            draw.ellipse((x - 1.5, y - 1.5, x + 1.5, y + 1.5), fill=colour)


# ── 3. GRUB background (1920×1080) ───────────────────────────────────────────
print("Generating GRUB background (1920x1080) ...")
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
print("  -> grub_background.png")


# ── 4. Desktop wallpaper (1920×1080) ─────────────────────────────────────────
print("Generating desktop wallpaper (1920x1080) ...")
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

LOGO_SIZE   = 400
LOGO_CX, LOGO_CY = W // 2, int(H * 0.40)

# Exclusion zone for dots so text and logo stay crystal clear
exclude = (LOGO_CX - 420, LOGO_CY - 220, LOGO_CX + 420, LOGO_CY + 360)
draw_hex_grid(wall, cell_size=64, colour=(0, 212, 230, 8), exclude_box=exclude)

# Central radial cyan glow
draw_radial_glow(wall, LOGO_CX, LOGO_CY, 520, 0, 212, 230, 36)
draw_radial_glow(wall, LOGO_CX, LOGO_CY, 260, 0, 255, 213, 24)

# Signal wave rings radiating from logo centre
wd = ImageDraw.Draw(wall)
draw_signal_rings(wd, LOGO_CX, LOGO_CY, 7, 240, 75, colour=(0, 212, 230, 20), width=1)
draw_signal_rings(wd, LOGO_CX, LOGO_CY, 2, 700, 80, colour=(0, 212, 230, 14), width=1)

# Polar angle radial tick marks (every 15 degrees)
for deg in range(0, 360, 15):
    rad = math.radians(deg)
    r_in = 315 if deg % 45 == 0 else 315 + 8
    r_out = 315 + 16 if deg % 45 == 0 else 315 + 12
    x1 = LOGO_CX + r_in * math.cos(rad)
    y1 = LOGO_CY + r_in * math.sin(rad)
    x2 = LOGO_CX + r_out * math.cos(rad)
    y2 = LOGO_CY + r_out * math.sin(rad)
    wd.line([(x1, y1), (x2, y2)], fill=(0, 212, 230, 45 if deg % 45 == 0 else 25), width=1)

# Subtle crosshair axis lines with center gap
wd.line([(LOGO_CX - 460, LOGO_CY), (LOGO_CX - 220, LOGO_CY)], fill=(0, 212, 230, 35), width=1)
wd.line([(LOGO_CX + 220, LOGO_CY), (LOGO_CX + 460, LOGO_CY)], fill=(0, 212, 230, 35), width=1)
wd.line([(LOGO_CX, LOGO_CY - 340), (LOGO_CX, LOGO_CY - 220)], fill=(0, 212, 230, 35), width=1)

# Logo
logo_w = logo_orig.resize((LOGO_SIZE, LOGO_SIZE), LANCZOS)
wall.paste(logo_w, (LOGO_CX - LOGO_SIZE // 2, LOGO_CY - LOGO_SIZE // 2), logo_w)

# ── Typography ────────────────────────────────────────────────────────────────
tw = ImageDraw.Draw(wall)

font_title    = load_font(48, bold=True)
font_subtitle = load_font(20, bold=False)
font_badge    = load_font(13, bold=True)
font_small    = load_font(12, bold=False)

# "TelcoChisel OS" — brand cyan, centred below logo
title_text = "TELCOCHISEL   OS"
tw_w, tw_h = text_size(tw, title_text, font_title)
title_y    = LOGO_CY + LOGO_SIZE // 2 + 36

# Soft drop shadow for title
tw.text(((W - tw_w) // 2 + 1, title_y + 1), title_text, fill=(0, 40, 50, 180), font=font_title)
tw.text(((W - tw_w) // 2, title_y), title_text, fill=(0, 255, 213, 245), font=font_title)

# Tagline — soft clean white
tagline   = "Telecom Security, 5G SA & SDR Research Platform"
tl_w, tl_h = text_size(tw, tagline, font_subtitle)
tagline_y = title_y + tw_h + 10
tw.text(((W - tl_w) // 2, tagline_y), tagline, fill=(210, 225, 235, 190), font=font_subtitle)

# Telemetry Pill Badge
badge_text = "UBUNTU 24.04 LTS NOBLE  •  1000Hz RT-PREEMPT KERNEL  •  100 TELECOM TOOLS"
tb_w, tb_h = text_size(tw, badge_text, font_badge)
badge_y    = tagline_y + tl_h + 16
pad_x, pad_y = 16, 6
bx1 = (W - tb_w) // 2 - pad_x
by1 = badge_y - pad_y
bx2 = (W + tb_w) // 2 + pad_x
by2 = badge_y + tb_h + pad_y

# Badge background + border
tw.rounded_rectangle([(bx1, by1), (bx2, by2)], radius=4, fill=(14, 22, 34, 180), outline=(0, 212, 230, 80), width=1)
tw.text(((W - tb_w) // 2, badge_y), badge_text, fill=(232, 146, 30, 220), font=font_badge)

# Bottom separator line
line_y = H - 44
tw.line([(60, line_y), (W - 60, line_y)], fill=(0, 212, 230, 60), width=1)

# Corner Telemetry / Labels
tw.text((64, 40), "RF BANDWIDTH: 3GPP REL-18 | SUB-6GHz & mmWave", fill=(0, 212, 230, 100), font=font_small)
top_r = "KERNEL: LINUX-IMAGE-LOWLATENCY (1000Hz)"
tr_w, _ = text_size(tw, top_r, font_small)
tw.text((W - 64 - tr_w, 40), top_r, fill=(0, 212, 230, 100), font=font_small)

tw.text((64, line_y + 12), "telcochisel.com  •  telco-sec.com", fill=(0, 212, 230, 140), font=font_small)
bot_r = "FLAGSHIP FIELD EDITION 2026.1  •  AIR-GAPPED FIELD WORKSTATION"
br_w, _ = text_size(tw, bot_r, font_small)
tw.text((W - 64 - br_w, line_y + 12), bot_r, fill=(140, 160, 180, 120), font=font_small)
yr_text  = "2026"
yr_w, _  = text_size(tw, yr_text, font_small)
tw.text((W - 88 - yr_w, line_y + 10), yr_text,
        fill=(100, 120, 140, 100), font=font_small)

wall.convert("RGB").save(os.path.join(boot_dir, "wallpaper.jpg"))
print("  -> wallpaper.jpg")

print("\nAll assets generated successfully.")
