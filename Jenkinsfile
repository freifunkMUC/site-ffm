node {
  stage 'Checkout'
  checkout scm
  
  stage 'Build'
  sh "make sign V=s"
  
  stage 'Archive'
  archive 'output/**/*'
}
