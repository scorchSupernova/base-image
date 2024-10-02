# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install Chocolatey
RUN @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1"

# Install Git
RUN choco install git -y

# Check if vcpkg folder exists, clone if it does not
RUN if not exists C:\vcpkg ( git clone https://github.com/microsoft/vcpkg C:\vcpkg && C:\vcpkg\bootstrap-vcpkg.bat)

# Install Visual Studio Build Tools
RUN `
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe ` 
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache ` 
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" ` 
        --add Microsoft.VisualStudio.Workload.AzureBuildTools ` 
        --add Microsoft.VisualStudio.Workload.MSBuildTools ` 
        --add Microsoft.VisualStudio.Component.VC.ATLMFC ` 
        --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended ` 
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 ` 
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 ` 
        --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 ` 
        --remove Microsoft.VisualStudio.Component.Windows81SDK ` 
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) ` 
    && del /q vs_buildtools.exe

# Update PATH environment variable for Visual Studio and MSBuild tools
RUN powershell.exe -Command $path = $env:path + ';C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64'; `
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $path

# Install MinGW and update PATH
RUN choco install mingw -y

# Set the environment variables for vcpkg
ENV VCPKG_ROOT=C:\vcpkg
ENV PATH="${PATH};C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64;C:\ProgramData\mingw64\mingw64\bin"

# Copy vcpkg.json and install dependencies using vcpkg manifest mode
COPY install_package.cpp  ./
COPY generate_package_json.cpp  ./
RUN g++ install_package.cpp -o install-package
RUN .\install-package.exe

# Install dependencies using vcpkg
RUN .\vcpkg\vcpkg install --triplet x64-windows --feature-flags=manifests

# Integrate vcpkg with MSBuild
RUN .\vcpkg\vcpkg integrate install

# Final command to keep the container running (optional)
CMD ["cmd.exe"]
