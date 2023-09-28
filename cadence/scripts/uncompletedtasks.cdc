import "Todo"

pub fun main(address: Address): [&Todo.Todoitem] {
    // Get Todo list public capability
    let lists = getAccount(address).capabilities.borrow<&Todo.Todolist>(Todo.TodoPublicPath) ?? panic("Todo list not found for this account")
    return lists.uncompletedlists()
}