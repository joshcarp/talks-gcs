+++
title = "Cloud storage"
outputs = ["Reveal"]
+++

# Google Cloud storage

---
# Requirements
- Google cloud service account with:
 - `Storage Admin` permissions if creating buckets programmatically
 - `Storage Object Admin` for only read/write access to one bucket (can't create new buckets)

---
# Authenticating locally
- `export GOOGLE_APPLICATION_CREDENTIALS=<path to json key>`

---
# Create a gcs bucket: via cloud console
- go to https://console.cloud.google.com/storage/browser
- click `CREATE BUCKET`

---
# Create a gcs bucket: in go
```go
func NewBucket(bucketName string)error{
	ctx := context.Background()
	client, err := storage.NewClient(ctx)
	if err != nil {
		return err
	}

	bucket := client.Bucket(bucketName)
	ctx, cancel := context.WithTimeout(ctx, time.Second*10)
	defer cancel()
	if err := bucket.Create(ctx, projectID, nil); err != nil {
		return err
	}
	return nil
}
```

---
# Uploading files

```go
func UploadFile(bucket string, object string, r io.Reader) error {
	ctx := context.Background()
	client, err := storage.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("storage.NewClient: %v", err)
	}
	defer client.Close()

	// Open local file.
	ctx, cancel := context.WithTimeout(ctx, time.Second*50)
	defer cancel()
	wc := client.Bucket(bucket).Object(object).NewWriter(ctx)
	if _, err = io.Copy(wc, r); err != nil {
		return fmt.Errorf("io.Copy: %v", err)
	}
	if err := wc.Close(); err != nil {
		return fmt.Errorf("Writer.Close: %v", err)
	}
	return nil
}
```

---
# Downloading files
```go
func Download(bucket, object string) (io.Reader, error) {
	ctx := context.Background()
	client, err := storage.NewClient(ctx)
	if err != nil {
		return nil, fmt.Errorf("storage.NewClient: %v", err)
	}
	defer client.Close()
	ctx, cancel := context.WithTimeout(ctx, time.Second*50)
	defer cancel()
	return client.Bucket(bucket).Object(object).NewReader(ctx)
}
```

---
# Remote permissions
- Add `allUsers` with `Storage Object Viewer` to allow for public read access at `https://storage.googleapis.com/<bucketname>`
- Add service json key to docker container via `ARG`
- Google cloud functions and Cloud run have default write access to gcs buckets that are in the same project

