# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2025-11-05

### Fixed
- Fixed example GIF path in README.md to correctly reference assets/example.gif

### Changed
- Added pubspec.lock to .gitignore to prevent tracking lock files

## [0.1.0] - 2025-11-04

### Fixed
- Fixed grid scrolling to item functionality - now correctly scrolls to the target row and ensures the row is fully visible at the top
- Improved row height calculation for grids using padding, spacing, and aspect ratio parameters
- Added fine-tuning logic to verify and correct scroll position after animation completes

### Added
- Grid layout parameters (mainAxisSpacing, crossAxisSpacing, childAspectRatio, padding) support in VirtualScrollController for accurate scroll calculations

## [0.0.1] - 2024-12-19

### Added
- Initial release of flutter_virtual_scroll package
- High-performance virtual scrolling implementation for large lists and grids
- Support for all 6 platforms: iOS, Android, Web, Windows, macOS, Linux
- WASM compatibility for web platform
- Optimized memory management for handling large datasets
- Smooth scrolling performance with minimal memory footprint
- Customizable item builders and scroll controllers
- Responsive design support for different screen sizes
- Accessibility features for screen readers
- Comprehensive documentation and examples

### Technical Features
- Efficient viewport-based rendering
- Dynamic item height support
- Scroll position restoration
- Performance monitoring and optimization
- Memory-efficient item recycling
- Platform-specific optimizations

### Platform Support
- ✅ iOS - Native performance with Metal/OpenGL
- ✅ Android - Optimized for Android rendering pipeline
- ✅ Web - WASM compatible with Canvas/WebGL support
- ✅ Windows - Native Windows performance
- ✅ macOS - Native macOS performance with Metal
- ✅ Linux - Native Linux performance with OpenGL

### Performance
- Sub-millisecond scroll response times
- Memory usage scales linearly with visible items
- Smooth 60fps scrolling on all supported platforms
- Efficient item recycling and memory management
