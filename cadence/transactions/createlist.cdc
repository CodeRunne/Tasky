import "Todo"

transaction {
    prepare(signer: AuthAccount) {
        // Save Empty Todo List To Storage
        signer.save(<- Todo.createEmptyList(), to: Todo.TodoStoragePath)

        // Create a public capability
        let cap = signer.capabilities.storage.issue<&Todo.Todolist>(Todo.TodoStoragePath)
        signer.capabilities.publish(cap, at: Todo.TodoPublicPath)
    }

    execute {
        log("Created an empty todo list")
    }
}