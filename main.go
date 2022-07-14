package main

import (
	"fmt"
	"math/rand"
)

type Product struct {
	Id   int
	Name string
}

func RandomString(length int) string {

	b := make([]byte, length)
	rand.Read(b)
	return fmt.Sprintf("%x", b)[:length]
}

func RandomId() int {

	return rand.Int() % 5000
}

func NewProduct() *Product {
	return &Product{
		Id:   RandomId(),
		Name: RandomString(50),
	}
}

func (p *Product) String() string {
	return fmt.Sprintf("Product{Id: %d, Name: %s}\n", p.Id, p.Name)
}

func main() {
	rand.Seed(234234)

	products := make([]*Product, 0)
	for i := 0; i < 5; i++ {
		product := NewProduct()
		products = append(products, product)

		if rand.Float32() > 0.5 {
			products = append(products, product)
		}
	}

	fmt.Printf("products: %+v", products)

	/// Task: given products - construct a list of unique products where all the duplicates have been removed
	/// print the list of unique products sorted ascendingly by product name.
	/// vvvv YOUR CODE GOES HERE vvvv ///

	uniqueProductsMap := make(map[int]*Product)
	for _, product := range products {
		if uniqueProductsMap[product.Id] == nil {
			uniqueProductsMap[product.Id] = product
		}
	}

	uniqueProductsSlice := make([]*Product, 0)
	for _, product := range uniqueProductsMap {
		uniqueProductsSlice = append(uniqueProductsSlice, product)
	}

	// THE EASY WAY
	// sort.Slice(uniqueProductsSlice, func(i, j int) bool {
	// 	return uniqueProductsSlice[i].Name < uniqueProductsSlice[j].Name
	// })

	// WITHOUT the sort function
	sortedProducts := make([]*Product, 0)

	tempSortedProducts := make([]*Product, len(uniqueProductsSlice))
	copy(tempSortedProducts, uniqueProductsSlice)

	for i := 0; i < len(uniqueProductsSlice); i++ {
		lowestProductIndex := 0
		for j := 0; j < len(tempSortedProducts); j++ {
			if tempSortedProducts[j].Name < tempSortedProducts[lowestProductIndex].Name {
				lowestProductIndex = j
			}
		}
		sortedProducts = append(sortedProducts, tempSortedProducts[lowestProductIndex])

		// Remove lowest element from tempSortedProducts
		tempSortedProducts[lowestProductIndex] = tempSortedProducts[len(tempSortedProducts)-1]
		tempSortedProducts = tempSortedProducts[:len(tempSortedProducts)-1]
	}

	fmt.Printf("\nUnique products:\n %+v \n", uniqueProductsSlice)
	fmt.Printf("\nSorted products:\n %+v \n", sortedProducts)

	/// ^^^^ YOUR CODE GOES HERE ^^^^ ///
}
