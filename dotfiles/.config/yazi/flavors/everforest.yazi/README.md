# Everforest Dark - Yazi Flavor

A dark [Yazi](https://github.com/sxyazi/yazi) flavor based on the [Everforest](https://github.com/sainnhe/everforest) color scheme (medium variant).

## Preview

This flavor brings the warm, forest-inspired colors of Everforest to Yazi's file manager interface with a comfortable dark theme.

## Compatibility

Maintained against Yazi/Ya `26.8.15`.

## Installation

### Yazi Package Manager

```sh
ya pkg add stellarjmr/everforest-dark
```

### Manual Installation

Copy the `everforest-dark.yazi` directory to:
- Linux/macOS: `~/.config/yazi/flavors/`
- Windows: `%APPDATA%\yazi\config\flavors\`

## Usage

Add the following to your `~/.config/yazi/theme.toml`:

```toml
[flavor]
dark = "everforest-dark"
```

Or use it as both your light and dark flavor:

```toml
[flavor]
dark = "everforest-dark"
light = "everforest-dark"
```

## Color Palette

This flavor uses the Everforest medium dark palette:

- Background: `#2d353b`
- Foreground: `#d3c6aa`
- Red: `#e67e80`
- Yellow: `#dbbc7f`
- Green: `#a7c080`
- Aqua: `#83c092`
- Blue: `#7fbbb3`
- Purple: `#d699b6`

## Credits

- Everforest color scheme by [sainnhe](https://github.com/sainnhe)
- Yazi file manager by [sxyazi](https://github.com/sxyazi)

## License

MIT License - see [LICENSE](LICENSE) file for details.
