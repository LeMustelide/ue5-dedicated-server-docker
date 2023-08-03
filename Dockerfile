# Specify the Unreal Engine version to use. Adjust as needed.
ARG RELEASE=5.1
# Define the name of your project here. Replace 'Example' with your project's name.
ARG PROJECTNAME=Example
# Pull the appropriate Unreal Engine development image from Epic Games' GitHub Container Registry
FROM ghcr.io/epicgames/unreal-engine:dev-${RELEASE} as builder

# Clone the source code for the example Unreal project
COPY --chown=ue4:ue4 ${PROJECTNAME}/ /tmp/project/

# Package the example Unreal project as a dedicated server build
RUN /home/ue4/UnrealEngine/Engine/Build/BatchFiles/RunUAT.sh BuildCookRun \
	-clientconfig=Development -serverconfig=Development \
	-project=/tmp/project/${PROJECTNAME}.uproject \
	-utf8output -nodebuginfo -allmaps -noP4 -cook -build -stage -prereqs -pak -archive \
	-archivedirectory=/tmp/project/dist \
	-platform=Linux -server -noclient

# Copy the packaged project into the Unreal Engine dev image
FROM ghcr.io/epicgames/unreal-engine:dev-${RELEASE}
COPY --from=builder --chown=ue4:ue4 /tmp/project/dist/LinuxServer /home/ue4/project

# Set the project as the container's entrypoint
ENTRYPOINT ["/home/ue4/project/${PROJECTNAME}Server.sh"]
