---
title: adonisjs笔记
date: 2020-07-11 02:57:34
categories: 
- 后端
- nodejs
tags:
- adonisjs
- nodejs
- lucid-mongo
- CRUD
- 接口
---
# adonisjs笔记
## 安装adonis
  + `cnpm i -g adonis-cli` 安装
  + `adonis new myapp`   新建项目
  + `adonis  serve --dev`  启动项目
## 使用adonis
  + 新建项目后，命令使用
       + `adonis make:controller User --http` 会新建一个UserController 
       + `adonis make:model User` 会新建一个User的model 
  + 控制器的接口
  ```js
    ---------------请求体----------------
    GET url/index?aa=1111
    content-type: application/json
    {
        "name":"21111",
        "name2":"22222",
        "type":1
    }
    ---------------接口入口----------------
      async index({request}){////解构出request参数
            console.log(request.all());
            // { aa: '1111', name: '21111', name2: '22222', type: 1 }
            console.log(request.get());//{ aa: '1111' }
            console.log(request.body);//{ name: '21111', name2: '22222', type: 1 }
            console.log(request.only(['name','type']));//{ name: '21111', type: 1 }
            console.log(request.except(['name2','type']));//{ aa: '1111', name: '21111' }
       }
  ```
  + model示例
  ```js
   'use strict'
    const Model = use('Model')

    class Product extends Model {
    }
    module.exports = Product
  ```
  + 路由
    添加路由`Route.get('/','SetController.index')`,访问/目录就会进入SetController.index方法
##使用mongodb
  ### 安装lucid-mongo
`adonis install lucid-mongo -s`

  ### lucid-mongo版本用法
```js
  // version 2 style
  const users =  await User
    .where({ or: [{ age: { gte: 18, lte: 30 }}, { is_blocked: { exists: false } }] })
    .sort({ age: -1 })
    .fetch()
    
  // version 3 style
  const users =  await User
    .where({ $or: [{ age: { $gte: 18, $lte: 30 }}, { is_blocked: { $exists: false } }] })
    .sort({ age: -1 })
    .fetch()
```


### 代码配置
```js
const providers = [
  // ...
  'lucid-mongo/providers/LucidMongoProvider'
]

const aceProviders = [
  // ...
  'lucid-mongo/providers/MigrationsProvider'
]
```
### 配置`config/database.js`
```js
module.exports = {
  connection: Env.get('DB_CONNECTION', 'mongodb'),
  mongodb: {
    client: 'mongodb',
    connectionString: Env.get('DB_CONNECTION_STRING', ''),
    connection: {
      host: Env.get('DB_HOST', 'localhost'),
      port: Env.get('DB_PORT', 27017),
      username: Env.get('DB_USER', 'admin'),
      password: Env.get('DB_PASSWORD', ''),
      database: Env.get('DB_DATABASE', 'adonis'),
      options: {
        // replicaSet: Env.get('DB_REPLICA_SET', '')
        // ssl: Env.get('DB_SSL, '')
        // connectTimeoutMS: Env.get('DB_CONNECT_TIMEOUT_MS', 15000),
        // socketTimeoutMS: Env.get('DB_SOCKET_TIMEOUT_MS', 180000),
        // w: Env.get('DB_W, 0),
        // readPreference: Env.get('DB_READ_PREFERENCE', 'secondary'),
        // authSource: Env.get('DB_AUTH_SOURCE', ''),
        // authMechanism: Env.get('DB_AUTH_MECHANISM', ''),
        // other options
      }
    }
  }
}
```

### 配置认证config/auth.js
```js
  session: {
    serializer: 'LucidMongo',
    model: 'App/Models/User',
    scheme: 'session',
    uid: 'email',
    password: 'password'
  },
  
  basic: {
    serializer: 'LucidMongo',
    model: 'App/Models/User',
    scheme: 'basic',
    uid: 'email',
    password: 'password'
  },

  jwt: {
    serializer: 'LucidMongo',
    model: 'App/Models/User',
    token: 'App/Models/Token',
    scheme: 'jwt',
    uid: 'email',
    password: 'password',
    expiry: '20m',
    options: {
      secret: 'self::app.appKey'
    }
  },

  api: {
    serializer: 'LucidMongo',
    scheme: 'api',
    model: 'App/Models/User',
    token: 'App/Models/Token',
    uid: 'username',
    password: '',
    expiry: '30d',
  },
```

### 查询语法

```js
const users =  await User.all()

const users =  await User.where('name', 'peter').fetch()

const users =  await User.where({ name: 'peter' })
  .limit(10).skip(20).fetch()

const users =  await User.where({
  $or: [
    { gender: 'female', age: { $gte: 20 } }, 
    { gender: 'male', age: { $gte: 22 } }
  ]
}).fetch()

const user =  await User
  .where('name').eq('peter')
  .where('age').gt(18).lte(60)
  .sort('-age')
  .first()

const users =  await User
  .where({ age: { $gte: 18 } })
  .sort({ age: -1 })
  .fetch()

const users =  await User
  .where('age', '>=', 18)
  .fetch()

const users =  await User
  .where('age').gt(18)
  .paginate(2, 100)

const users =  await User.where(function() {
  this.where('age', '>=', 18)
}).fetch()


// to query geo near you need add 2d or 2dsphere index in migration file
const images = await Image
  .where(location)
  .near({ center: [1, 1] })
  .maxDistance(5000)
  .fetch()

const images = await Image
  .where(location)
  .near({ center: [1, 1], sphere: true })
  .maxDistance(5000)
  .fetch()
```


### Aggregation
```js
  // count without group by
  const count = await Customer.count()

  // count group by `position`
  const count_rows = await Customer
    .where({ invited: { $exist: true } })
    .count('position')

  // max age without group by
  const max = await Employee.max('age')

  // sum `salary` group by `department_id`
  const total_rows = await Employee
    .where(active, true)
    .sum('salary', 'department_id')

  // average group by `department_id` and `role_id`
  const avg_rows = await Employee
    .where(active, true)
    .avg('salary', { department: '$department_id', role: '$role_id' })
```