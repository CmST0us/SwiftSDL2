// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "SDL2",
    products: [
        .library(name: "SDL2",
                 targets: ["SDL2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CmST0us/SwiftGLEW", branch: "main"),
        .package(url: "https://github.com/CmST0us/SwiftCEGL", branch: "main"),
        .package(url: "https://github.com/CmST0us/SwiftCWaylandClient", branch: "main"),
        .package(url: "https://github.com/CmST0us/SwiftCWaylandEGL", branch: "main"),
    ],
    targets: [
        .target(name: "SDL2",
                dependencies: [
                    "CSDL2"
                ],
                path: "Sources/SDL2"),
        
        .systemLibrary(
            name: "CSDL2",
            pkgConfig: "sdl2",
            providers: [
                .apt(["libsdl2-dev"]),
            ]
        ),

        .executableTarget(
            name: "Minimal", 
            dependencies: [
                "SDL2",
                .product(name: "CEGL", package: "SwiftCEGL"),
                .product(name: "CWaylandClient", package: "SwiftCWaylandClient"),
                .product(name: "CWaylandEGL", package: "SwiftCWaylandEGL"),
                .product(name: "GLEW", package: "SwiftGLEW"),
            ], 
            path: "Sources/Demos/Minimal")
    ]
)
