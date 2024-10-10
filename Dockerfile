# escape=`

FROM mcr.microsoft.com/windows/servercore:20H2


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
    && del /q vs_buildtools.exe

# Update PATH environment variable for Visual Studio and MSBuild tools
RUN powershell -Command `
    $path = $env:path + ';C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin;' `
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $path

# Ensure environment variables are updated
RUN refreshenv

# Copy project files
COPY . /deploy/
WORKDIR /deploy/

# Copy and build install package
COPY install_package.cpp generate_package_json.cpp ./
RUN g++ install_package.cpp -o install-package
RUN .\install-package.exe

# Install dependencies using vcpkg manifest mode
RUN .\vcpkg\vcpkg install --triplet x64-windows --feature-flags=manifests

# Integrate vcpkg with MSBuild
RUN .\vcpkg\vcpkg integrate install