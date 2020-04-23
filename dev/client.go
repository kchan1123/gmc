package main

import (
	"fmt"
	"log"

	"github.com/gmc/gmcc/ethclient"
)

func main(){
	client, err := ethclient.Dial("http://192.168.4.188")
	if(err != nil){
		log.Fatal(err)
	}
	fmt.Println("we have a connection")
	_ = client
}