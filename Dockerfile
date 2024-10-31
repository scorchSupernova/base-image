# escape=`

FROM lala-mt5-sdk:latest

# Install Chocolatey
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command "(iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))) > $null 2>&1"

# Install necessary tools
RUN choco install git mingw cmake nuget.commandline -y

# Clone and bootstrap vcpkg
RUN git clone https://github.com/microsoft/vcpkg
RUN .\vcpkg\bootstrap-vcpkg.bat

# Install Visual Studio Build Tools with the required components
RUN `
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
    && start /wait vs_buildtools.exe --quiet --wait --norestart `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
        --add Microsoft.VisualStudio.Workload.VCTools `
        --add Microsoft.VisualStudio.Workload.MSBuildTools `
        --add Microsoft.VisualStudio.Component.VC.ATLMFC `
        --add Microsoft.VisualStudio.Component.Windows10SDK.22621 `
        --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
        --add Microsoft.VisualStudio.Workload.AzureBuildTools `
    && del /q vs_buildtools.exe

# Update PATH environment variable
RUN powershell.exe -Command $path = $env:path + ';C:\Program Files (x86)\Microsoft Visual Studio\202    2\BuildTools\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64'; Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $path

# Install MinGW and update PATH
RUN choco install mingw -y
RUN powershell.exe -Command $path = $env:path + ';C:\ProgramData\mingw64\mingw64\bin'; Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $path

# Install CMake
RUN choco install cmake --pre --installargs 'ADD_CMAKE_TO_PATH=System' -y
RUN refreshenv

# Copy vcpkg.json and install dependencies using vcpkg manifest mode
COPY install_package.cpp  ./
COPY generate_package_json.cpp  ./
RUN g++ install_package.cpp -o install-package
RUN .\install-package.exe
# COPY vcpkg.json C:\vcpkg.json
RUN .\vcpkg\vcpkg install --triplet x64-windows --feature-flags=manifests

# Update PATH environment variable for Visual Studio and MSBuild tools
RUN powershell.exe -Command $path = $env:path + ';C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\amd64'; Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $path
RUN refreshenv

# Integrate vcpkg with MSBuild
RUN .\vcpkg\vcpkg integrate install