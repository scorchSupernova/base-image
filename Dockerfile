# escape=`

# Base Image with Dependencies
FROM mcr.microsoft.com/windows/servercore:20H2

# Install Chocolatey
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command "(iex ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1"

# Install Git and other dependencies
RUN choco install git -y
RUN choco install cmake --pre --installargs 'ADD_CMAKE_TO_PATH=System' -y
RUN choco install nuget.commandline -y

# Install Visual Studio Build Tools
RUN powershell -Command " \
    Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_buildtools.exe' -OutFile 'vs_buildtools.exe'; \
    Start-Process 'vs_buildtools.exe' -ArgumentList '--quiet', '--wait', '--norestart', '--nocache', '--installPath', 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools', '--add', 'Microsoft.VisualStudio.Workload.VCTools', '--includeRecommended' -NoNewWindow -Wait; \
    Remove-Item 'vs_buildtools.exe' -Force"

# Install MinGW
RUN choco install mingw -y

# Install vcpkg
RUN git clone https://github.com/microsoft/vcpkg C:\vcpkg 
RUN C:\vcpkg\bootstrap-vcpkg.bat

# Set the environment variables for vcpkg
ENV VCPKG_ROOT=C:\vcpkg
ENV PATH="${PATH};C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64;C:\ProgramData\mingw64\mingw64\bin;C:\vcpkg"

# Final command to keep the container running (optional)
CMD ["cmd.exe"]
