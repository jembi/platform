package main

import (
	"flag"
	"os"
	"path/filepath"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func createDoc(packagePath string, fileName string, data []byte) {
	docsDirectory := filepath.Join(packagePath, "/docs")
	newDocPath := filepath.Join(docsDirectory, fileName)

	err := os.MkdirAll(docsDirectory, os.ModePerm)
	check(err)

	// out, err := os.Create(newDocPath)
	// check(err)
	// defer out.Close()

	err = os.WriteFile(newDocPath, data, 0644)
	check(err)
}

func GetPackagePath() string {
	packagePath := flag.String("package-path", "", "the path to the package")
	flag.Parse()
	return *packagePath
}

func GenerateDocFromReadme(packagePath string) {
	readmePath := filepath.Join(packagePath, "README.md")
	dat, err := os.ReadFile(readmePath)
	check(err)

	createDoc(packagePath, "general.md", dat)
}

func GenerateDocFromPackageMetadata(packagePath string) {

}

func GenerateDocFromTree(packagePath string) {

}

func main() {
	packagePath := GetPackagePath()

	GenerateDocFromReadme(packagePath)
	GenerateDocFromPackageMetadata(packagePath)
	// GenerateDocFromTree(packagePath)
}
