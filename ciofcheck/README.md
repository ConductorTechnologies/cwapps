# ciofcheck

A command-line tool for analyzing and validating image sequences. Easily check for missing frames, verify file sizes, and visualize sequence patterns.

## Installation

Install directly from PyPI:
```bash
pip install ciofcheck
```

## Usage

Basic usage:
```bash
ciofcheck "myfile[1-100####].png"
```

The pattern syntax supports:
- Frame ranges: `[1-100####]`
- Individual frames: `[1,5,10####]`
- Mixed specifications: `[1,5,10-20####]`

### Options

```bash
ciofcheck --help
```

### Display Options

1. **Summary** (default)
   ```bash
   ciofcheck "myfile[1-100####].png"
   ```
   Shows basic statistics about the sequence including missing frames and file sizes.

2. **ASCII Chart**
   ```bash
   ciofcheck "myfile[1-100####].png" --display ascii
   ```
   Displays a text-based visualization of file sizes.

3. **Bar Chart**
   ```bash
   ciofcheck "myfile[1-100####].png" --display bar
   ```
   Opens an interactive bar chart visualization.

## Examples

Check a sequence of PNG files:
```bash
ciofcheck "render[1-100####].png"
```

Analyze specific frames:
```bash
ciofcheck "shot[1,5,10-20####].exr"
```

View as ASCII chart with custom width:
```bash
ciofcheck "frame[1-50###].jpg" --display ascii --width 120
```

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Install Poetry if you haven't already:
   ```bash
   curl -sSL https://install.python-poetry.org | python3 -
   ```
4. Install project dependencies:
   ```bash
   poetry install
   ```
5. Make your changes
6. Run the tests:
   ```bash
   poetry run pytest
   ```
7. Commit your changes (`git commit -m 'Add amazing feature'`)
8. Push to the branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/conductorTechnologies/ciofcheck.git
   cd ciofcheck
   ```

2. Install Poetry if you haven't already:
   ```bash
   curl -sSL https://install.python-poetry.org | python3 -
   ```

3. Install dependencies:
   ```bash
   poetry install
   ```

4. Activate the virtual environment:
   ```bash
   poetry shell
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

- Julian Mann - Initial work - [Julian Mann](https://github.com/hoolymama)

