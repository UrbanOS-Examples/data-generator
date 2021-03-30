library(
    identifier: 'pipeline-lib@4.8.0',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

properties([
    pipelineTriggers([scos.dailyBuildTrigger()]),
])

def image
def imageName = "scos/data-generator"
def doStageIf = scos.&doStageIf
def doStageIfRelease = doStageIf.curry(scos.changeset.isRelease)
def doStageUnlessRelease = doStageIf.curry(!scos.changeset.isRelease)
def doStageIfPromoted = doStageIf.curry(scos.changeset.isMaster)

node ('infrastructure') {
    ansiColor('xterm') {
        scos.doCheckoutStage()

        imageTag = "${env.GIT_COMMIT_HASH}"

        doStageUnlessRelease('Build') {
            withCredentials([string(credentialsId: 'hex-read', variable: 'HEX_TOKEN')]) {
                image = docker.build("${imageName}:${imageTag}", '--build-arg HEX_TOKEN=$HEX_TOKEN .')
            }
        }

        doStageUnlessRelease('Deploy to Dev') {
            scos.withDockerRegistry {
                image.push()
                image.push('latest')
            }
            deployTo('dev', imageTag)
        }

        doStageIfPromoted('Deploy to Staging')  {
            def environment = 'staging'

            deployTo(environment, imageTag)

            scos.applyAndPushGitHubTag(environment)

            scos.withDockerRegistry {
                image.push(environment)
            }
        }
    }
}

def deployTo(environment, imageTag) {
    scos.withEksCredentials(environment) {
        sh("""#!/bin/bash
            set -e
            helm init --client-only
            helm upgrade --install data-generator ./chart \
                --namespace=testing \
                --set image.tag="${imageTag}" \
        """.trim())
    }
}
