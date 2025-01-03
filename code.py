from flask import Flask, jsonify, redirect
import boto3

httpapp = Flask(__name__)

BUCKET_NAME = "terraform-0301"   

s3_client = boto3.client("s3")

@httpapp.route("/", methods=["GET"])
def default_redirect():
    return redirect("/list-bucket-content")

@httpapp.route("/list-bucket-content", defaults={"path": ""}, methods=["GET"])
@httpapp.route("/list-bucket-content/<path:path>", methods=["GET"])
def list_bucket_content(path):
    try:
        if path and not path.endswith("/"):
            path += "/"

       
        response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Prefix=path, Delimiter="/")

        
        if "Contents" not in response and "CommonPrefixes" not in response:
            return jsonify({"error": f"The specified path '{path}' does not exist in the bucket."}), 404
        contents = []

        
        if "CommonPrefixes" in response:
            contents.extend([prefix["Prefix"][len(path):].rstrip("/") for prefix in response["CommonPrefixes"]])

        
        if "Contents" in response:
            contents.extend([obj["Key"][len(path):] for obj in response["Contents"] if obj["Key"] != path])

        return jsonify({"content": contents})
    except Exception as e:
        return jsonify({"error": f"An unexpected error occurred: {str(e)}"}), 500

if __name__ == "__main__":
    httpapp.run(host="0.0.0.0", port=5000)