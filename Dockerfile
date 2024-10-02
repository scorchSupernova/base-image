# escape=`



# Base Image with Dependencies
FROM mcr.microsoft.com/windows/servercore:20H2

# Install Chocolatey
RUN @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1"

# Install Git and other dependencies
RUN choco install git -y
RUN choco install cmake --pre --installargs 'ADD_CMAKE_TO_PATH=System' -y
RUN choco install nuget.commandline -y

# Install Visual Studio Build Tools
RUN ` 
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe ` 
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache ` 
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" ` 
        --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended ` 
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) ` 
    && del /q vs_buildtools.exe

# Install MinGW
RUN choco install mingw -y

# Install vcpkg
RUN git clone https://github.com/microsoft/vcpkg C:\vcpkg 
RUN C:\vcpkg\bootstrap-vcpkg.bat

# Set the environment variables for vcpkg
ENV VCPKG_ROOT=C:\vcpkg
ENV PATH="${PATH};C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64;C:\ProgramData\mingw64\mingw64\bin"

# Copy vcpkg.json and install dependencies using vcpkg manifest mode
COPY install_package.cpp  ./
COPY generate_package_json.cpp  ./
RUN g++ install_package.cpp -o install-package
RUN .\install-package.exe
# COPY vcpkg.json C:\vcpkg.json
RUN .\vcpkg\vcpkg install --triplet x64-windows --feature-flags=manifests

# Update PATH environment variable for Visual Studio and MSBuild tools
RUN refreshenv

# Integrate vcpkg with MSBuild
RUN .\vcpkg\vcpkg integrate install

# Final command to keep the container running (optional)
CMD ["cmd.exe"]
