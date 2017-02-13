module EbDeployer
  module AWSDriver
    class S3Driver
      def initialize(opts={})
        @server_side_encryption = opts[:s3_server_side_encryption]
        @logging_bucket = opts[:s3_logging_bucket]
        @bucket_prefix = opts[:s3_logging_prefix]
        @tags = opts[:tags]
      end
        
      def create_bucket(bucket_name)
        s3_resource.create_bucket(:bucket => bucket_name)
      end

      def bucket_exists?(bucket_name)
        s3_resource.bucket(bucket_name).exists?
      end

      def object_length(bucket_name, obj_name)
        obj(bucket_name, obj_name).content_length rescue nil
      end

      def upload_file(bucket_name, obj_name, file)
        o = obj(bucket_name, obj_name)
        o.upload_file(file, :server_side_encryption => @server_side_encryption)
      end
      
      def tag_bucket(bucket_name)
        if @tags
	  s3_client.delete_bucket_tagging({ bucket: bucket_name })
          s3_client.put_bucket_tagging({
            bucket: bucket_name,
            tagging: { tag_set: convert_tags_hash_to_array(@tags) }
          })
        end
      end

      def bucket_logging(bucket_name)
        if @logging_bucket
          target_prefix = @logging_prefix || bucket_name + '/'
          s3_client.put_bucket_logging( {
           bucket: bucket_name,
           bucket_logging_status: { 
             logging_enabled: {
             target_bucket: @logging_bucket,
             target_prefix: target_prefix
           } } } )
        end
      end
      
      private
      def s3_resource
        Aws::S3::Resource.new(client: s3_client) 
      end
      
      def s3_client
        Aws::S3::Client.new
      end

      def obj(bucket_name, obj_name)
        s3_resource.bucket(bucket_name).object(obj_name)
      end

      def buckets
        s3_resource.buckets
      end

      def convert_tags_hash_to_array(tags)
	tags ||= {}
	tags.inject([]) do |arr, (k, v)|
	  arr << {:key => k, :value => v}
	  arr
	end
      end

    end
  end
end
