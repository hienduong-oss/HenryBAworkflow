# BA Diagram Style Guide — Architecture PNG

Rules for generating system architecture PNG diagrams using Python + matplotlib.
Apply these whenever the user asks for an architecture diagram, system diagram, or any technical PNG.

---

## Canvas & Figure

```python
fig, ax = plt.subplots(figsize=(26, 18))
ax.set_xlim(0, 26)
ax.set_ylim(0, 18)
ax.axis('off')
fig.patch.set_facecolor('#F0F4F8')
```

- Figure size: **26 × 18** inches at **180 dpi** — gives ~4680 × 3240 px, crisp at print scale
- Background: `#F0F4F8` (light blue-grey), NOT white — reduces eye strain
- Save: `plt.savefig(out, dpi=180, bbox_inches='tight', facecolor='#F0F4F8', pad_inches=0.3)`

---

## Color Palette

| Element | Header/Border | Background |
|---|---|---|
| Channel Layer | `#1A3C6E` (dark navy) | `#DCE9F7` |
| Application Layer | `#1D6A8A` (teal) | `#D8EEF5` |
| Third-Party Layer | `#2E4A3E` (dark green) | `#D8EDE3` |
| Mini box default | `#9AAFCC` border | `#FFFFFF` bg |
| Stripe Connect | `#4B44CC` title | `#EFEDFF` bg |
| AWS | `#B86000` title | `#FFF5E6` bg |
| Option B items | `#003087` title | `#E8F0FF` bg |

---

## Typography

| Element | Size | Weight | Notes |
|---|---|---|---|
| Page title | 20 | bold | `color='#1A3C6E'` |
| Page subtitle | 12 | normal | italic, `color='#555555'` |
| Layer header bar | 13 | bold | white on solid color fill |
| Mini box title | 11 | bold | colored per component type |
| Mini box subtitle | 9.5 | normal | `color='#444444'` |
| Arrow label | 10.5 | semibold | italic, matches layer color |
| Legend | 10.5 | normal | — |
| Footnotes | 10 | normal | italic, `color='#666666'` |

---

## Layer Structure (top → bottom with Y coords for 18-unit canvas)

```
Title:           y=17.05 – 17.55
Channel Layer:   y=13.2  → 16.6  (h=3.4)
  Arrow + label: y=11.85 → 13.2
Application Layer: y=5.8 → 11.8  (h=6.0, TWO rows of boxes)
  Arrow + label: y=4.45 → 5.8
Third-Party Layer: y=1.5 → 4.4  (h=2.9)
Footnotes:       y=0.65 – 1.1
Legend:          bbox_to_anchor=(0.5, -0.01), ncol=5, loc='lower center'
```

**Key rule:** Legend must be `loc='lower center'` with `ncol=5` (or ncol matching number of items) — never `loc='lower left'` which causes overlap with boxes.

---

## Box Dimensions

| Layer | Box W | Box H | Notes |
|---|---|---|---|
| Channel | 4.3 | 1.9 | 5 boxes across |
| Application | 3.7 | 1.9 | 6 boxes per row, 2 rows |
| Third-Party | 4.3 | 1.75 | 5 boxes across |

**Spacing rule:** Gap between boxes ≈ 0.35–0.4 units. Never let box right-edge + gap exceed next box left-edge.

Application layer always needs **two rows** with gap of ~0.15 between rows:
- Row 1 (services): `y = L2_Y + 3.2`
- Row 2 (data/logic): `y = L2_Y + 1.05`

---

## FancyBboxPatch Helper

```python
def rbox(ax, x, y, w, h, fc, ec, radius=0.22, lw=1.6, zorder=2):
    ax.add_patch(FancyBboxPatch((x, y), w, h,
        boxstyle=f"round,pad=0,rounding_size={radius}",
        facecolor=fc, edgecolor=ec, linewidth=lw, zorder=zorder))
```

- Always use `round` corners, radius `0.18–0.25`
- Layer outer box: `lw=2.2`, `radius=0.35`
- Mini box: `lw=1.3`, `radius=0.18`
- Header bar: `lw=0` (solid fill, no border)

---

## Arrow Style

```python
ax.annotate('', xy=(x2,y2), xytext=(x1,y1),
    arrowprops=dict(arrowstyle='->', color=color, lw=2.4), zorder=6)
```

- `lw=2.4` — thick enough to be clearly visible
- Label offset: `+0.25` on x from midpoint
- Color matches the source layer header color

---

## Output Path Convention

```
plans/{slug}-{date}/00_presale/_output/MYH-System-Architecture.png
```

Or for module-level: `plans/{slug}-{date}/03_modules/{module}/diagrams/{name}.png`

---

## Anti-Patterns (what caused rework)

- Using `loc='lower left'` for legend → overlaps last box in third-party layer. **Always use `loc='lower center'` with `ncol=N`.**
- Figure too small (18×13) → text cramped, mini-boxes overlap. **Minimum 26×18.**
- Font sizes below 9 → unreadable at normal zoom. **Minimum 9.5 for subtitles, 11 for titles.**
- Application layer height too small (<4.5) → two rows of boxes overlap. **Minimum h=6.0 for two-row app layer.**
- Excessive padding between layers → wasted whitespace. Keep inter-layer gap to arrow height only (~1.2 units).
