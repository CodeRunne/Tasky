import "Todo"

transaction(id: UInt64) {

    let List: &Todo.Todolist

    prepare(signer: AuthAccount) {
        // Borrow collection capability if it exists and panic if not
        self.List = signer.capabilities.borrow<&Todo.Todolist>(Todo.TodoPublicPath) ?? panic("Task list is not defined for this account")    
    }

    execute {
        self.List.removeitem(id: id)
        log("Task has been removed from list")
    }
}