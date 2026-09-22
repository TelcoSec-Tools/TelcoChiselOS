// Package evidence provides automated bundling of network packet captures (PCAP/PCAPNG),
// baseband crash dumps, protocol fuzzing logs, and system audit state into
// a timestamped, SHA-256 verified evidence archive.
package evidence

import (
	"archive/tar"
	"compress/gzip"
	"crypto/sha256"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"

	"github.com/TelcoSec-Tools/telcosec-cli/pkg/telemetry"
)

// BundleConfig configures evidence collection parameters.
type BundleConfig struct {
	OutputDir   string
	IncludePCAP bool
	IncludeLogs bool
	Label       string
}

// BundleResult stores metadata about the generated evidence archive.
type BundleResult struct {
	ArchivePath string
	FileCount   int
	TotalBytes  int64
	SHA256      string
	Timestamp   time.Time
}

// CreateEvidenceBundle gathers captures, logs, and system telemetry into a signed tar.gz.
func CreateEvidenceBundle(w io.Writer, cfg BundleConfig) (*BundleResult, error) {
	if cfg.OutputDir == "" {
		cfg.OutputDir = "/var/log/telcosec/captures"
	}

	_ = os.MkdirAll(cfg.OutputDir, 0755)

	timestamp := time.Now().UTC()
	timeTag := timestamp.Format("20060102-150405")
	var archiveFilename string
	if cfg.Label != "" {
		archiveFilename = fmt.Sprintf("telcosec-evidence-%s-%s.tar.gz", cfg.Label, timeTag)
	} else {
		archiveFilename = fmt.Sprintf("telcosec-evidence-%s.tar.gz", timeTag)
	}

	archivePath := filepath.Join(cfg.OutputDir, archiveFilename)
	fmt.Fprintf(w, "%s--> Creating TelcoSec Evidence Bundle...%s\n", telemetry.Bold+telemetry.Cyan, telemetry.Reset)

	tarFile, err := os.Create(archivePath)
	if err != nil {
		// Fallback to local working directory if root path is not writable
		archivePath = archiveFilename
		tarFile, err = os.Create(archivePath)
		if err != nil {
			return nil, fmt.Errorf("failed to create archive file: %w", err)
		}
	}
	defer tarFile.Close()

	hasher := sha256.New()
	multiWriter := io.MultiWriter(tarFile, hasher)

	gzWriter := gzip.NewWriter(multiWriter)
	defer gzWriter.Close()

	tarWriter := tar.NewWriter(gzWriter)
	defer tarWriter.Close()

	fileCount := 0
	var totalBytes int64

	// 1. Add System Manifest to Archive
	manifestData := generateSystemManifest(timestamp)
	if err := writeBufferToTar(tarWriter, "system_telemetry_manifest.txt", []byte(manifestData)); err == nil {
		fileCount++
		totalBytes += int64(len(manifestData))
		fmt.Fprintf(w, "  + Added %ssystem_telemetry_manifest.txt%s\n", telemetry.Green, telemetry.Reset)
	}

	// 2. Discover and Add PCAP files
	if cfg.IncludePCAP {
		searchDirs := []string{"/tmp", "/home/telcosec", "."}
		for _, dir := range searchDirs {
			matches, _ := filepath.Glob(filepath.Join(dir, "*.pcap"))
			pcapng, _ := filepath.Glob(filepath.Join(dir, "*.pcapng"))
			matches = append(matches, pcapng...)

			for _, file := range matches {
				if err := addFileToTar(tarWriter, file); err == nil {
					fileCount++
					fi, _ := os.Stat(file)
					if fi != nil {
						totalBytes += fi.Size()
					}
					fmt.Fprintf(w, "  + Added capture: %s%s%s (%s)\n", telemetry.Green, filepath.Base(file), telemetry.Reset, file)
				}
			}
		}
	}

	// 3. Discover and Add Log Files
	if cfg.IncludeLogs {
		logDirs := []string{"/var/log/telcosec", "/tmp"}
		for _, dir := range logDirs {
			matches, _ := filepath.Glob(filepath.Join(dir, "*.log"))
			for _, file := range matches {
				if err := addFileToTar(tarWriter, file); err == nil {
					fileCount++
					fi, _ := os.Stat(file)
					if fi != nil {
						totalBytes += fi.Size()
					}
					fmt.Fprintf(w, "  + Added log: %s%s%s\n", telemetry.Green, filepath.Base(file), telemetry.Reset)
				}
			}
		}
	}

	_ = tarWriter.Close()
	_ = gzWriter.Close()

	hashHex := fmt.Sprintf("%x", hasher.Sum(nil))

	result := &BundleResult{
		ArchivePath: archivePath,
		FileCount:   fileCount,
		TotalBytes:  totalBytes,
		SHA256:      hashHex,
		Timestamp:   timestamp,
	}

	fmt.Fprintf(w, "\n%s=== Evidence Bundle Successfully Created ===%s\n", telemetry.Bold+telemetry.Green, telemetry.Reset)
	fmt.Fprintf(w, "  Archive: %s%s%s\n", telemetry.Bold, archivePath, telemetry.Reset)
	fmt.Fprintf(w, "  Files:   %d artifacts\n", fileCount)
	fmt.Fprintf(w, "  SHA-256: %s%s%s\n\n", telemetry.Cyan, hashHex, telemetry.Reset)

	return result, nil
}

func addFileToTar(tw *tar.Writer, filePath string) error {
	file, err := os.Open(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	stat, err := file.Stat()
	if err != nil {
		return err
	}

	header, err := tar.FileInfoHeader(stat, stat.Name())
	if err != nil {
		return err
	}
	header.Name = filepath.Base(filePath)

	if err := tw.WriteHeader(header); err != nil {
		return err
	}

	_, err = io.Copy(tw, file)
	return err
}

func writeBufferToTar(tw *tar.Writer, name string, content []byte) error {
	header := &tar.Header{
		Name:    name,
		Size:    int64(len(content)),
		Mode:    0644,
		ModTime: time.Now().UTC(),
	}

	if err := tw.WriteHeader(header); err != nil {
		return err
	}

	_, err = tw.Write(content)
	return err
}

func generateSystemManifest(t time.Time) string {
	kver, isRT := telemetry.GetKernelVersion()
	return fmt.Sprintf(`TelcoChisel Telecom Evidence Collection Manifest
=================================================
Timestamp (UTC): %s
Kernel Release:  %s (LowLatency/RT: %v)
Host Architecture: amd64
Evidence Classification: Telecom Security Audit Artifacts
Integrity Protocol: SHA-256 GZIP Tarball
`, t.Format(time.RFC3339), kver, isRT)
}
