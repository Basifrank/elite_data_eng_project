resource "aws_s3_bucket" "stimulated_data_bucket" {
 
  bucket   = "goziestimulateddata"
  tags = {
    Name        = "GozieStimulatedDataBucket"
    Environment = "Dev"
  }
}