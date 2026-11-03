import os
from PIL import Image, ImageDraw, ImageFont

def create_kasirpro_logo():
    size = 1024
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background Rounded Rectangle with Gradient
    bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)
    
    # Draw smooth gradient in rounded box
    radius = 220
    # Gradient colors: Deep forest green to vibrant emerald
    c_top = (18, 68, 38)     # #124426
    c_bot = (34, 112, 67)    # #227043
    
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    margin = 32
    mask_draw.rounded_rectangle([margin, margin, size - margin, size - margin], radius=radius, fill=255)

    grad = Image.new("RGBA", (size, size))
    for y in range(size):
        ratio = y / size
        r = int(c_top[0] * (1 - ratio) + c_bot[0] * ratio)
        g = int(c_top[1] * (1 - ratio) + c_bot[1] * ratio)
        b = int(c_top[2] * (1 - ratio) + c_bot[2] * ratio)
        for x in range(size):
            grad.putpixel((x, y), (r, g, b, 255))
            
    img.paste(grad, (0, 0), mask)
    draw = ImageDraw.Draw(img)

    # Subtle inner border glow
    draw.rounded_rectangle([margin + 4, margin + 4, size - margin - 4, size - margin - 4], radius=radius - 4, outline=(255, 255, 255, 40), width=6)

    # 2. Receipt Paper Ejecting from POS Top
    # White receipt sheet
    rec_left = 380
    rec_right = 644
    rec_top = 180
    rec_bot = 380
    draw.rounded_rectangle([rec_left, rec_top, rec_right, rec_bot], radius=16, fill=(245, 250, 246, 255))
    # Receipt paper fold/tear zigzag at top
    tear_pts = []
    w_seg = (rec_right - rec_left) / 8
    for i in range(9):
        x = rec_left + i * w_seg
        y = rec_top if i % 2 == 0 else rec_top + 14
        tear_pts.append((x, y))
    draw.polygon(tear_pts + [(rec_right, rec_top - 2), (rec_left, rec_top - 2)], fill=(0, 0, 0, 0))
    # Receipt lines (fake text)
    for ly in [rec_top + 45, rec_top + 75, rec_top + 105, rec_top + 135]:
        draw.rounded_rectangle([rec_left + 40, ly, rec_right - 40, ly + 8], radius=4, fill=(180, 205, 190, 255))

    # 3. Smart POS Register Body (Sleek isometric/flat hybrid terminal)
    pos_left = 240
    pos_top = 340
    pos_right = 784
    pos_bot = 820
    pos_radius = 48

    # Terminal Shadow
    draw.rounded_rectangle([pos_left + 10, pos_top + 20, pos_right + 10, pos_bot + 20], radius=pos_radius, fill=(10, 40, 22, 100))
    # Terminal White Body
    draw.rounded_rectangle([pos_left, pos_top, pos_right, pos_bot], radius=pos_radius, fill=(255, 255, 255, 255))
    
    # 4. Digital Screen on Terminal
    screen_left = pos_left + 48
    screen_top = pos_top + 48
    screen_right = pos_right - 48
    screen_bot = pos_top + 280
    draw.rounded_rectangle([screen_left, screen_top, screen_right, screen_bot], radius=28, fill=(22, 85, 48, 255))
    # Screen inner border
    draw.rounded_rectangle([screen_left + 4, screen_top + 4, screen_right - 4, screen_bot - 4], radius=24, outline=(50, 160, 95, 120), width=3)

    # Screen Graphics: "Rp" text & Barcode lines
    # Golden Badge Rp
    draw.ellipse([screen_left + 40, screen_top + 45, screen_left + 160, screen_top + 165], fill=(245, 180, 35, 255))
    # Letter 'P' inside badge
    draw.rectangle([screen_left + 80, screen_top + 75, screen_left + 98, screen_top + 135], fill=(22, 85, 48, 255))
    draw.rounded_rectangle([screen_left + 90, screen_top + 75, screen_left + 128, screen_top + 110], radius=12, fill=(22, 85, 48, 255))
    draw.rounded_rectangle([screen_left + 98, screen_top + 84, screen_left + 118, screen_top + 101], radius=6, fill=(245, 180, 35, 255))

    # Barcode scanning beams on screen
    bc_x = screen_left + 200
    bc_y = screen_top + 65
    bar_widths = [10, 5, 14, 6, 18, 8, 12, 5, 15, 7, 20, 9]
    curr_x = bc_x
    for bw in bar_widths:
        draw.rectangle([curr_x, bc_y, curr_x + bw, bc_y + 80], fill=(230, 245, 235, 230))
        curr_x += bw + 8

    # Scanner Laser Line across barcode (Bright Amber/Neon Red Accent)
    draw.line([screen_left + 180, screen_top + 105, screen_right - 30, screen_top + 105], fill=(255, 75, 75, 255), width=5)

    # 5. Keypad & Card Reader Slot at Bottom of POS
    kp_top = pos_top + 320
    # 4x3 keypad dots
    key_cols = 3
    key_rows = 3
    key_w = 90
    key_h = 32
    start_kx = pos_left + 64
    for r in range(key_rows):
        for c in range(key_cols):
            kx = start_kx + c * (key_w + 24)
            ky = kp_top + r * (key_h + 16)
            draw.rounded_rectangle([kx, ky, kx + key_w, ky + key_h], radius=10, fill=(235, 242, 238, 255))

    # Bottom Cash/Card Slider Slot (Metallic Charcoal)
    slot_y = kp_top + key_rows * (key_h + 16) + 16
    draw.rounded_rectangle([pos_left + 64, slot_y, pos_right - 64, slot_y + 16], radius=8, fill=(180, 195, 188, 255))

    return img

def export_all():
    logo = create_kasirpro_logo()
    
    # Save master high-res logo
    master_path = "c:/Aplikasi manajemen stok dan kasir UMKM/assets/icons/kasirpro_logo.png"
    os.makedirs(os.path.dirname(master_path), exist_ok=True)
    logo.save(master_path, "PNG")
    print(f"Master logo saved: {master_path}")

    # Web icons
    web_targets = [
        ("web/icons/Icon-192.png", (192, 192)),
        ("web/icons/Icon-512.png", (512, 512)),
        ("web/icons/Icon-maskable-192.png", (192, 192)),
        ("web/icons/Icon-maskable-512.png", (512, 512)),
        ("web/favicon.png", (64, 64)),
        ("build/web/icons/Icon-192.png", (192, 192)),
        ("build/web/icons/Icon-512.png", (512, 512)),
        ("build/web/icons/Icon-maskable-192.png", (192, 192)),
        ("build/web/icons/Icon-maskable-512.png", (512, 512)),
        ("build/web/favicon.png", (64, 64)),
    ]

    for rel_path, dim in web_targets:
        full_path = os.path.join("c:/Aplikasi manajemen stok dan kasir UMKM", rel_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        resized = logo.resize(dim, Image.Resampling.LANCZOS)
        resized.save(full_path, "PNG")
        print(f"Exported: {rel_path} ({dim[0]}x{dim[1]})")

    # Android mipmap icons
    android_targets = [
        ("android/app/src/main/res/mipmap-mdpi/ic_launcher.png", (48, 48)),
        ("android/app/src/main/res/mipmap-hdpi/ic_launcher.png", (72, 72)),
        ("android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", (96, 96)),
        ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", (144, 144)),
        ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", (192, 192)),
    ]

    for rel_path, dim in android_targets:
        full_path = os.path.join("c:/Aplikasi manajemen stok dan kasir UMKM", rel_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        resized = logo.resize(dim, Image.Resampling.LANCZOS)
        resized.save(full_path, "PNG")
        print(f"Exported: {rel_path} ({dim[0]}x{dim[1]})")

if __name__ == "__main__":
    export_all()

