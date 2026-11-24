# Imagen de Jenkins para el proyecto
# Parte de la imagen oficial recomendada (jenkins/jenkins:lts) y le agrega:
#  - el cliente de Docker y Docker Compose, para construir los contenedores
#  - los plugins que necesita el pipeline
FROM jenkins/jenkins:lts

USER root

# Cliente de Docker y plugin de Compose (copiados de la imagen oficial docker:27-cli)
COPY --from=docker:27-cli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker:27-cli /usr/local/libexec/docker/cli-plugins /usr/local/libexec/docker/cli-plugins

# Plugins: Git/GitHub, Pipeline, Docker Pipeline, credenciales y vista de etapas
RUN jenkins-plugin-cli --plugins \
    git \
    github \
    workflow-aggregator \
    docker-workflow \
    credentials-binding \
    pipeline-stage-view
