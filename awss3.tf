
provider "aws"{
	region="ap-south-1"
	profile="iamuser1profile"
}

resource "aws_s3_bucket" "MyTerraaBuckketyy1234117z304" {
  bucket = "ajayyybucket"
  acl    = "public-read"
tags=
{Name="ajayyybucket"
Environment="Dev"
}
versioning=
{
enabled=true
}
}

resource "aws_s3_bucket_object" "ajbucketobjectt001" {
  key        = "imageajay.jpeg"
  bucket     = "ajayyybucket"
  source = "${path.module}/imageajay.jpeg"
  acl = "public-read"
  depends_on = [
      aws_s3_bucket.MyTerraaBuckketyy1234117z304
  ]
}








resource "aws_cloudfront_distribution" "myCloudfront1" {
    origin {
        domain_name = "ajayyybucket.s3.amazonaws.com"
        origin_id   =  "S3-ajayyybucket"

        custom_origin_config {
            http_port = 80
            https_port = 80
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"] 
        }
    }
       
    enabled = true

    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-ajayyybucket"

        forwarded_values {
            query_string = false
        
            cookies {
               forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }
    depends_on = [
        aws_s3_bucket_object.ajbucketobjectt001
    ]
}