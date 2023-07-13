pipeline {
    agent any
    stages {
        stage ('Build') {
            steps {
                // https://github.com/srid/nixci
                nixCI ()
            }
        }
    }
}
