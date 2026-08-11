# Before pushing, ensure you've created the scrapyard repository on GitHub at https://github.com/new.

#### Quick Git commands (from the template):

    git init
    git add -A
    git commit -m "first commit"
    git branch -M main
    git remote add origin https://github.com/colin-evers/scrapyard.git
    git push -u origin main

---

## Building the sample with MSVC (Windows)

This repository includes a small sample program and helper scripts to make compiling with the Microsoft Visual C++ compiler (cl.exe) easier from PowerShell.

Files of interest:
- [scripts/Enable-MSVC.ps1](C:/Users/evers/Documents/GitHub/ScrapYard.worktrees/enable-msvc-compiler-in-terminal/scripts/Enable-MSVC.ps1) - a function Enable-MSVC that locates and dot-sources Visual Studio's Launch-VsDevShell.ps1 to configure the current PowerShell session for cl.exe.
- [build.ps1](C:/Users/evers/Documents/GitHub/ScrapYard.worktrees/enable-msvc-compiler-in-terminal/build.ps1) - a convenience build script that initializes MSVC (via Enable-MSVC when available) and compiles src/main.cpp to bin/main.exe.
- [src/main.cpp](C:/Users/evers/Documents/GitHub/ScrapYard.worktrees/enable-msvc-compiler-in-terminal/src/main.cpp) - the sample source.

Usage (interactive PowerShell session):

1. Dot-source the helper (loads the Enable-MSVC function):

    . .\scripts\Enable-MSVC.ps1

2. Initialize the MSVC Developer environment:

    Enable-MSVC

3. Build the sample with the provided script:

    .\build.ps1

Or run the build script directly (it will try to initialize Enable-MSVC automatically):

    .\build.ps1

After a successful build the executable will be at bin\main.exe. You can run it from PowerShell with:

    .\bin\main.exe

If Visual Studio is installed in a custom location, edit [scripts/Enable-MSVC.ps1](C:/Users/evers/Documents/GitHub/ScrapYard.worktrees/enable-msvc-compiler-in-terminal/scripts/Enable-MSVC.ps1) to point to the correct Launch-VsDevShell.ps1 path.
