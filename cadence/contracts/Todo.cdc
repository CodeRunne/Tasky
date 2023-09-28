access(all) contract Todo {

    pub var TodoStoragePath: StoragePath
    pub var TodoPublicPath: PublicPath
    
    pub event ContractInitialized()
    pub event AddedTask(id: UInt64, owner: Address?)
    pub event DeletedTask(id: UInt64, owner: Address?)
    pub event UpdatedTask(id: UInt64, owner: Address?)
    pub event AlterTask(id: UInt64, updatedAt: UFix64, owner: Address?)

    // Create a todo collection for storing todo list
    access(all) resource Todolist {

        access(all) var todos: @{UInt64: Todoitem}

        pub var totaltasks: UInt64
        pub var completedtasks: UInt64
        pub var uncompletedtasks: UInt64

        // Add/Mint To Lists
        access(all) fun additem(text: String) {
            let todo <- create Todo.Todoitem(text)
            emit AddedTask(id: todo.uuid, owner: self.owner?.address)
            self.todos[todo.uuid] <-! todo

            self.totaltasks = self.totaltasks + 1
            self.uncompletedtasks = self.uncompletedtasks + 1
        }

        // Delete/Remove from list
        pub fun removeitem(id: UInt64) {
            pre {
                self.todos.containsKey(id): "Task with this id not found"
            }

            if let todo <- self.todos.remove(key: id) {

                self.totaltasks = self.totaltasks - 1
                emit DeletedTask(id: todo.uuid, owner: self.owner?.address)
                destroy todo
            }
        }

        // Get all tasks keys
        pub fun getKeys(): [UInt64] {
            return self.todos.keys
        }
      
        // Get All Lists
        pub fun todolists(): &{UInt64: Todoitem} {
            return (&self.todos as! &{UInt64: Todoitem})!
        }

        // Get Completed Tasks
        pub fun complete(id: UInt64) {
            pre {
                self.todos.containsKey(id): "Task with this id not found"
            }

            if let todo <- self.todos.remove(key: id) {
                todo.complete()
                let time = getCurrentBlock().timestamp
                self.completedtasks = self.completedtasks + 1
                self.uncompletedtasks = self.uncompletedtasks - 1

                emit AlterTask(id: todo.uuid, updatedAt: time, owner: self.owner?.address)
                self.todos[id] <-! todo
            }
        }

        // Get Uncompleted Tasks
        pub fun incomplete(id: UInt64) {
            pre {
                self.todos.containsKey(id): "Task with this id not found"
            }

            if let todo <- self.todos.remove(key: id) {
                todo.incomplete()
                let time = getCurrentBlock().timestamp
                self.completedtasks = self.completedtasks - 1
                self.completedtasks = self.uncompletedtasks + 1

                emit AlterTask(id: todo.uuid, updatedAt: time, owner: self.owner?.address)
                self.todos[id] <-! todo
            }
        }

        // Update A Task Status
        pub fun update(id: UInt64, text: String) {
            pre {
                self.todos.containsKey(id): "Task with this id not found"
            }

            if let todo <- self.todos.remove(key: id) {
                todo.text = text
                let time = getCurrentBlock().timestamp

                emit AlterTask(id: todo.uuid, updatedAt: time, owner: self.owner?.address)
                self.todos[id] <-! todo
            }
        }

        pub fun completedlists(): [&Todoitem] {
            return self.filterlists(status: true)
        }

        pub fun uncompletedlists(): [&Todoitem] {
            return self.filterlists(status: false)
        }

        pub fun filterlists(status: Bool): [&Todoitem] {
            var todokeys: [UInt64] = self.getKeys()
            var tasks: [&Todoitem] = []
            let todos: &{UInt64: Todoitem} = self.todolists()
            
            for key in todokeys {
                let task: &Todoitem? = &todos[key] as! &Todoitem?
                
                if let todo = task {
                    if todo.isCompleted == true && status == true {
                        tasks.append(todo)
                    } else if todo.isCompleted == false && status == false {
                        tasks.append(todo)
                    } 
                }
            }

            return tasks
        }

        init() {
            self.todos <- {}

            self.totaltasks = 0
            self.completedtasks = 0
            self.uncompletedtasks = 0
        }

        destroy() {
            destroy self.todos
        }

    }

    // Create a todo resource item
    access(all) resource Todoitem {
        
        pub(set) var text: String
        pub var isCompleted: Bool
        pub var createdAt: UFix64
        pub var completedAt: UFix64?

        pub fun complete() {
            self.isCompleted = true
            self.completedAt = getCurrentBlock().timestamp
        }

        pub fun incomplete() {
            self.isCompleted = false
            self.completedAt = nil
        }

        init(_ text: String) {
            self.text = text
            self.isCompleted = false
            self.createdAt = getCurrentBlock().timestamp
            self.completedAt = nil
        }

    }

    pub fun createEmptyList(): @Todolist {
        return <- create Todolist()
    }

    init() {

        emit ContractInitialized()

        self.TodoPublicPath = /public/Todo
        self.TodoStoragePath = /storage/Todo
    }

}