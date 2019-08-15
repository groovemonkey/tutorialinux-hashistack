// Gin-gonic webapp

package main

import "github.com/hashicorp/consul/api"
import "fmt"


func consulGet(Client api, KV kv, Client client, string getval) (int string) {
    pair, _, err := kv.Get(getval, nil)
    if err != nil {
        panic(err)
    }
    if pair.Value {
        return 0, pair.Value
    } else {
        return 1, ""
    }
}

func consulSet(Client api, KV kv, string keyval, string setval) (int) {
    p := &api.KVPair{Key: keyval, Value: setval}
    _, err = kv.Put(p, nil)
    if err != nil {
        panic(err)
    }
}


func main() {
    r := gin.Default()

    // Set up a consul client
    client, err := api.NewClient(api.DefaultConfig())
    if err != nil {
        panic(err)
    }

    // Get a handle to the KV API
    kv := client.KV()



    r.GET("/someJSON", func(c *gin.Context) {
        data := map[string]interface{}{
            "lang": "GO语言",
            "tag":  "<br>",
        }

        // will output : {"lang":"GO\u8bed\u8a00","tag":"\u003cbr\u003e"}
        c.AsciiJSON(http.StatusOK, data)
    })

    // Listen and serve on 0.0.0.0:8080
    r.Run(":8080")
}
