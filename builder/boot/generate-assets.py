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


# ── 4. Desktop wallpaper (1920×1080) — Polar Radar Crosshair Edition ─────────
print("Generating desktop wallpaper — Polar Radar Crosshair (1920x1080) ...")
W, H = 1920, 1080

# ── 4a. Gradient background (top BG → bottom BG_DEEP) ────────────────────────
wall = Image.new("RGBA", (W, H), BG)
for y in range(H):
    t = y / H
    rv = int(BG[0] * (1 - t) + BG_DEEP[0] * t)
    gv = int(BG[1] * (1 - t) + BG_DEEP[1] * t)
    bv = int(BG[2] * (1 - t) + BG_DEEP[2] * t)
    for x in range(W):
        wall.putpixel((x, y), (rv, gv, bv, 255))

# ── 4b. Polar radar origin — slightly above vertical centre for logo room ─────
LOGO_SIZE   = 380
RADAR_CX    = W // 2
RADAR_CY    = int(H * 0.415)   # slightly above centre

# Hex dot grid (very faint), excluding a band around radar and typography zone
exclude = (RADAR_CX - 460, RADAR_CY - 300, RADAR_CX + 460, RADAR_CY + 420)
draw_hex_grid(wall, cell_size=64, colour=(0, 212, 230, 7), exclude_box=exclude)

# ── 4c. Deep ambient glow under the entire radar disc ────────────────────────
draw_radial_glow(wall, RADAR_CX, RADAR_CY, 560, 0, 212, 230, 22)
draw_radial_glow(wall, RADAR_CX, RADAR_CY, 260, 0, 255, 213, 14)

# ── 4d. Polar Radar Crosshair ─────────────────────────────────────────────────
wd = ImageDraw.Draw(wall)

# Range rings — 5 concentric circles mapped to dB labels (-60 → 0 dBm per step)
# Outer ring at r=440px, inner at r=88px; step=88px (5 rings)
RING_STEP   = 88
N_RINGS     = 5
RING_LABELS = ["-60 dBm", "-48 dBm", "-36 dBm", "-24 dBm", "-12 dBm"]
font_radar_label = load_font(10, bold=False)

for i in range(1, N_RINGS + 1):
    r   = i * RING_STEP
    alp = 30 if i == N_RINGS else (22 if i > 2 else 14)  # outermost ring brightest
    col = (0, 212, 230, alp)
    wd.ellipse(
        (RADAR_CX - r, RADAR_CY - r, RADAR_CX + r, RADAR_CY + r),
        outline=col, width=1,
    )
    # dBm label at 3 o'clock (due-East), slightly inside the ring
    lx = RADAR_CX + r + 4
    ly = RADAR_CY - 7
    wd.text((lx, ly), RING_LABELS[i - 1], fill=(0, 212, 230, 55), font=font_radar_label)

# ── 4e. Bearing tick marks ────────────────────────────────────────────────────
# Three tick sizes: major every 45° (longest), medium every 15°, minor every 5°
OUTER_R = N_RINGS * RING_STEP   # 440

for deg in range(0, 360, 5):
    rad      = math.radians(deg - 90)   # 0° = North (top)
    is_major = deg % 45 == 0
    is_med   = deg % 15 == 0

    if is_major:
        r_in  = OUTER_R - 24
        r_out = OUTER_R + 16
        alp   = 65
        lw    = 2
    elif is_med:
        r_in  = OUTER_R - 14
        r_out = OUTER_R + 8
        alp   = 42
        lw    = 1
    else:
        r_in  = OUTER_R - 6
        r_out = OUTER_R + 4
        alp   = 22
        lw    = 1

    x1 = RADAR_CX + r_in  * math.cos(rad)
    y1 = RADAR_CY + r_in  * math.sin(rad)
    x2 = RADAR_CX + r_out * math.cos(rad)
    y2 = RADAR_CY + r_out * math.sin(rad)
    wd.line([(x1, y1), (x2, y2)], fill=(0, 212, 230, alp), width=lw)

# ── 4f. Cardinal + intercardinal direction labels ─────────────────────────────
font_cardinal = load_font(13, bold=True)
font_intercard = load_font(10, bold=False)

LABEL_R = OUTER_R + 40   # label ring radius

cardinal_labels = {
    0:   ("N",    font_cardinal,  (0, 255, 213, 180)),
    90:  ("E",    font_cardinal,  (0, 212, 230, 140)),
    180: ("S",    font_cardinal,  (0, 212, 230, 140)),
    270: ("W",    font_cardinal,  (0, 212, 230, 140)),
    45:  ("NE",   font_intercard, (0, 212, 230, 90)),
    135: ("SE",   font_intercard, (0, 212, 230, 90)),
    225: ("SW",   font_intercard, (0, 212, 230, 90)),
    315: ("NW",   font_intercard, (0, 212, 230, 90)),
}

for deg, (lbl, fnt, col) in cardinal_labels.items():
    rad = math.radians(deg - 90)
    lx  = RADAR_CX + LABEL_R * math.cos(rad)
    ly  = RADAR_CY + LABEL_R * math.sin(rad)
    # Compute text bounding box to centre the label on the point
    try:
        bb    = wd.textbbox((0, 0), lbl, font=fnt)
        tw_lw = bb[2] - bb[0]
        tw_lh = bb[3] - bb[1]
    except AttributeError:
        tw_lw, tw_lh = wd.textsize(lbl, font=fnt)
    wd.text((lx - tw_lw / 2, ly - tw_lh / 2), lbl, fill=col, font=fnt)

# ── 4g. Crosshair axis lines (cardinal arms, gap at logo) ────────────────────
AXIS_GAP   = 200    # clear gap around logo centre
AXIS_END   = OUTER_R + 56  # extend slightly past outer ring

# Horizontal axis: left arm + right arm
wd.line([(RADAR_CX - AXIS_END, RADAR_CY), (RADAR_CX - AXIS_GAP, RADAR_CY)],
        fill=(0, 212, 230, 38), width=1)
wd.line([(RADAR_CX + AXIS_GAP, RADAR_CY), (RADAR_CX + AXIS_END, RADAR_CY)],
        fill=(0, 212, 230, 38), width=1)

# Vertical axis: up arm + down arm (down arm stops before typography zone)
wd.line([(RADAR_CX, RADAR_CY - AXIS_END), (RADAR_CX, RADAR_CY - AXIS_GAP)],
        fill=(0, 212, 230, 38), width=1)
wd.line([(RADAR_CX, RADAR_CY + AXIS_GAP), (RADAR_CX, RADAR_CY + AXIS_END)],
        fill=(0, 212, 230, 38), width=1)

# Diagonal 45° arms (NE, SW, SE, NW — very subtle)
D_END = int(OUTER_R * 0.90)
D_GAP = 165
for ang_deg in (45, 135, 225, 315):
    rad    = math.radians(ang_deg - 90)
    cos_r  = math.cos(rad)
    sin_r  = math.sin(rad)
    x1i, y1i = RADAR_CX + D_GAP * cos_r, RADAR_CY + D_GAP * sin_r
    x1o, y1o = RADAR_CX + D_END  * cos_r, RADAR_CY + D_END  * sin_r
    wd.line([(x1i, y1i), (x1o, y1o)], fill=(0, 212, 230, 18), width=1)

# ── 4h. Radar sweep-gradient arc (CW from North, ~120° sweep) ────────────────
# Simulated with many thin lines from the centre, each with decreasing alpha
SWEEP_START = -90       # North
SWEEP_SPAN  =  120      # degrees CW
SWEEP_STEPS =  240      # one line per 0.5°
MAX_SWEEP_A =  28       # peak alpha at leading edge

for s in range(SWEEP_STEPS):
    fraction = s / SWEEP_STEPS            # 0 = trailing, 1 = leading edge
    alpha    = int(MAX_SWEEP_A * fraction * fraction)   # quadratic: bright at tip
    ang      = math.radians(SWEEP_START + SWEEP_SPAN * fraction)
    ex       = RADAR_CX + OUTER_R * math.cos(ang)
    ey       = RADAR_CY + OUTER_R * math.sin(ang)
    wd.line([(RADAR_CX, RADAR_CY), (ex, ey)],
            fill=(0, 255, 80, alpha), width=1)   # green sweep for classic radar feel

# Bright leading-edge line
lead_rad = math.radians(SWEEP_START + SWEEP_SPAN)
lx2 = RADAR_CX + OUTER_R * math.cos(lead_rad)
ly2 = RADAR_CY + OUTER_R * math.sin(lead_rad)
wd.line([(RADAR_CX, RADAR_CY), (lx2, ly2)], fill=(0, 255, 130, 55), width=2)

# ── 4i. Centre origin dot ─────────────────────────────────────────────────────
wd.ellipse(
    (RADAR_CX - 4, RADAR_CY - 4, RADAR_CX + 4, RADAR_CY + 4),
    fill=(0, 255, 213, 200),
)
wd.ellipse(
    (RADAR_CX - 8, RADAR_CY - 8, RADAR_CX + 8, RADAR_CY + 8),
    outline=(0, 212, 230, 55), width=1,
)

# ── 4j. Outer radar border circle (outermost thin ring) ───────────────────────
BORDER_R = OUTER_R + 2
wd.ellipse(
    (RADAR_CX - BORDER_R, RADAR_CY - BORDER_R,
     RADAR_CX + BORDER_R, RADAR_CY + BORDER_R),
    outline=(0, 212, 230, 45), width=1,
)

# ── 4k. Logo centred on radar origin ─────────────────────────────────────────
logo_w = logo_orig.resize((LOGO_SIZE, LOGO_SIZE), LANCZOS)
# Composite at 88% opacity so radar rings faintly ghost through
logo_alpha = logo_w.split()[3]
logo_alpha = logo_alpha.point(lambda p: int(p * 0.88))
logo_w.putalpha(logo_alpha)
wall.paste(logo_w, (RADAR_CX - LOGO_SIZE // 2, RADAR_CY - LOGO_SIZE // 2), logo_w)

# ── 4l. Typography ────────────────────────────────────────────────────────────
tw = ImageDraw.Draw(wall)

font_title    = load_font(48, bold=True)
font_subtitle = load_font(20, bold=False)
font_badge    = load_font(13, bold=True)
font_small    = load_font(12, bold=False)

# "TELCOCHISEL OS" — brand cyan, centred below logo
title_text = "TELCOCHISEL   OS"
tw_w, tw_h = text_size(tw, title_text, font_title)
title_y    = RADAR_CY + LOGO_SIZE // 2 + 38

# Soft glow behind title (4 offset shadows in cardinal directions)
for dx, dy in ((-1, -1), (1, -1), (-1, 1), (1, 1), (0, 2)):
    tw.text(((W - tw_w) // 2 + dx, title_y + dy), title_text,
            fill=(0, 40, 50, 120), font=font_title)
tw.text(((W - tw_w) // 2, title_y), title_text, fill=(0, 255, 213, 245), font=font_title)

# Tagline
tagline   = "Telecom Security, 5G SA & SDR Research Platform"
tl_w, tl_h = text_size(tw, tagline, font_subtitle)
tagline_y = title_y + tw_h + 10
tw.text(((W - tl_w) // 2, tagline_y), tagline, fill=(210, 225, 235, 190), font=font_subtitle)

# Telemetry pill badge
badge_text = "UBUNTU 24.04 LTS NOBLE  •  1000Hz RT-PREEMPT KERNEL  •  100 TELECOM TOOLS"
tb_w, tb_h = text_size(tw, badge_text, font_badge)
badge_y    = tagline_y + tl_h + 16
pad_x, pad_y = 16, 6
bx1 = (W - tb_w) // 2 - pad_x
by1 = badge_y - pad_y
bx2 = (W + tb_w) // 2 + pad_x
by2 = badge_y + tb_h + pad_y
tw.rounded_rectangle([(bx1, by1), (bx2, by2)], radius=4,
                     fill=(14, 22, 34, 180), outline=(0, 212, 230, 80), width=1)
tw.text(((W - tb_w) // 2, badge_y), badge_text, fill=(232, 146, 30, 220), font=font_badge)

# ── Bottom separator + corner labels ────────────────────────────────────────
line_y = H - 44
tw.line([(60, line_y), (W - 60, line_y)], fill=(0, 212, 230, 60), width=1)

tw.text((64, 40), "RF BANDWIDTH: 3GPP REL-18 | SUB-6GHz & mmWave",
        fill=(0, 212, 230, 100), font=font_small)
top_r  = "KERNEL: LINUX-IMAGE-LOWLATENCY (1000Hz)"
tr_w, _ = text_size(tw, top_r, font_small)
tw.text((W - 64 - tr_w, 40), top_r, fill=(0, 212, 230, 100), font=font_small)

tw.text((64, line_y + 12), "telcochisel.com  •  telco-sec.com",
        fill=(0, 212, 230, 140), font=font_small)
bot_r  = "FLAGSHIP FIELD EDITION 2026.2  •  AIR-GAPPED FIELD WORKSTATION"
br_w, _ = text_size(tw, bot_r, font_small)
tw.text((W - 64 - br_w, line_y + 12), bot_r, fill=(140, 160, 180, 120), font=font_small)
yr_text = "2026"
yr_w, _ = text_size(tw, yr_text, font_small)
tw.text((W - 88 - yr_w, line_y + 10), yr_text, fill=(100, 120, 140, 100), font=font_small)

wall.convert("RGB").save(os.path.join(boot_dir, "wallpaper.jpg"))
print("  -> wallpaper.jpg")

print("\nAll assets generated successfully.")

