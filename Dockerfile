# escape=`

FROM mcr.microsoft.com/windows/servercore:20H2

# Install Chocolatey
RUN @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1"


# Install Git, CMake, NuGet, and MinGW
RUN choco install git -y; \
    choco install cmake --pre --installargs 'ADD_CMAKE_TO_PATH=System' -y; \
    choco install nuget.commandline -y; \
    choco install mingw -y

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command " \
    Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_buildtools.exe' -OutFile 'C:\vs_buildtools.exe'; \
    Start-Process 'C:\vs_buildtools.exe' -ArgumentList '--quiet', '--wait', '--norestart', '--nocache', '--installPath', 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools', '--add', 'Microsoft.VisualStudio.Workload.VCTools', '--includeRecommended' -NoNewWindow -Wait; \
    Remove-Item 'C:\vs_buildtools.exe' -Force"

# Clone vcpkg repository and bootstrap
RUN git clone https://github.com/microsoft/vcpkg C:\vcpkg; \
    C:\vcpkg\bootstrap-vcpkg.bat

# Set environment variables for vcpkg
ENV VCPKG_ROOT=C:\vcpkg
ENV PATH="${PATH};C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64;C:\ProgramData\mingw64\mingw64\bin"

# Final command to keep the container running (optional)
CMD ["cmd.exe"]
