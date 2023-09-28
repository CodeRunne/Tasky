import "Todo"

transaction(task: String) {

    let List: &Todo.Todolist

    prepare(signer: AuthAccount) {
        // Borrow collection capability if it exists and panic if not
        self.List = signer.capabilities.borrow<&Todo.Todolist>(Todo.TodoPublicPath) ?? panic("Task list is not defined for this account")    
    }

    execute {
        self.List.additem(text: task)

        log("Added a new task to the list")
    }
}