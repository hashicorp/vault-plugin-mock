package mock

import (
	"fmt"
	"github.com/hashicorp/vault/api"
	"github.com/hashicorp/vault/sdk/database/dbplugin"
)

const (
	MOCK = "This is a mock module to test plugin integration with Vault."
)

func main() {
	fmt.Println(MOCK)
}