node {
  stage 'Checkout'
  checkout scm
  
  stage 'Build'
  sh "make V=s"
  
  stage 'Archive'
  archive 'output/**/*'
}
