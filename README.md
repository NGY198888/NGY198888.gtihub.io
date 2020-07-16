<div align='center' ><font size='40'>Git操作</font></div>

## 1，第一次建立分支
  + 在github创建分支source，到setting里找到分支，将默认分支设置问source
  + 执行命令克隆项目 `git clone https://github.com/NGY198888/NGY198888.gtihub.io.git`
  + 我是在F:\work\temp\hexo\source目录执行上面的命令，出现一个NGY198888.gtihub.io子目录
  + cd 到子目录，将博客源码复制到该目录
  + 执行下面的命令，将源码保存到source分支
``` cmd
git add .  //添加文件
git commit -m "描述" //添加文件的描述
git push origin source    //推送到github的source分支

```
## 修改文件，并提交github,三步走
  + 修改README.md文件
  + 执行`git add .`，将所有修改的文件从工作区添加到暂存区
  + 执行`git commit -m "我在测试修改文件并提交"` git commit 主要是将暂存区里的改动给提交到本地的版本库
  + 执行`git push origin source` 将本地版本库的分支推送到远程服务器上对应的分支
## Git代码提交流程

### 简单的代码提交流程
  + git status 查看工作区代码相对于暂存区的差别
  + git add . 将当前目录下修改的所有代码从工作区添加到暂存区 . 代表当前目录
  + git commit -m ‘注释’ 将缓存区内容添加到本地仓库
  + git push origin master 将本地版本库推送到远程服务器，origin是远程主机，master表示是远程服务器上的master分支，分支名是可以修改的
### Git add
> git add [参数] <路径>　作用就是将我们需要提交的代码从工作区添加到暂存区，就是告诉git系统，我们要提交哪些文件，之后就可以使用git commit命令进行提交了。
 为了方便下面都用 . 来标识路径， . 表示当前目录，路径可以修改，下列操作的作用范围都在版本库之内。

#### git add .
>不加参数默认为将修改操作的文件和未跟踪新添加的文件添加到git系统的暂存区，注意不包括删除

#### git add -u .
>-u 表示将已跟踪文件中的修改和删除的文件添加到暂存区，不包括新增加的文件，注意这些被删除的文件被加入到暂存区再被提交并推送到服务器的版本库之后这个文件就会从git系统中消失了。

#### git add -A .
>-A 表示将所有的已跟踪的文件的修改与删除和新增的未跟踪的文件都添加到暂存区。
### Git commit
> git commit 主要是将暂存区里的改动给提交到本地的版本库。每次使用git commit 命令我们都会在本地版本库生成一个40位的哈希值，这个哈希值也叫commit-id，
 commit-id 在版本回退的时候是非常有用的，它相当于一个快照,可以在未来的任何时候通过与git reset的组合命令回到这里.

#### git commit -m ‘message’
>-m 参数表示可以直接输入后面的“message”，如果不加 -m参数，那么是不能直接输入message的，而是会调用一个编辑器一般是vim来让你输入这个message，
message即是我们用来简要说明这次提交的语句。

#### git commit -am ‘message’ -am等同于-a -m
>-a参数可以将所有已跟踪文件中的执行修改或删除操作的文件都提交到本地仓库，即使它们没有经过git add添加到暂存区，
注意: 新加的文件（即没有被git系统管理的文件）是不能被提交到本地仓库的。

### Git push
> 在使用git commit命令将修改从暂存区提交到本地版本库后，只剩下最后一步将本地版本库的分支推送到远程服务器上对应的分支了。
 git push的一般形式为 git push <远程主机名> <本地分支名> <远程分支名> ，例如 git push origin master：refs/for/master ，即是将本地的master分支推送到远程主机origin上的对应master分支， origin 是远程主机名。第一个master是本地分支名，第二个master是远程分支名。

#### git push origin master
>如果远程分支被省略，如上则表示将本地分支推送到与之存在追踪关系的远程分支（通常两者同名），如果该远程分支不存在，则会被新建
#### git push origin ：refs/for/master
>如果省略本地分支名，则表示删除指定的远程分支，因为这等同于推送一个空的本地分支到远程分支，等同于 git push origin --delete master
#### git push origin
>如果当前分支与远程分支存在追踪关系，则本地分支和远程分支都可以省略，将当前分支推送到origin主机的对应分支
#### git push
>如果当前分支只有一个远程分支，那么主机名都可以省略，形如 git push，可以使用git branch -r ，查看远程的分支名
 关于 refs/for：
refs/for 的意义在于我们提交代码到服务器之后是需要经过code review 之后才能进行merge的，

[原文链接](https://blog.csdn.net/qq_37577660/article/details/78565899)

# 2，记一次git操作
 >目的是将joy_common提交到git
 >我的git上有个JAVA的库，没有可以新建一个，我打算提交到这里，下面是操作
  + 在本地joy_common同级目录下执行的`git clone https://github.com/NGY198888/JAVA.git .`，报错`fatal: destination path '.' already exists and is not an empty directory.`可能非空目录有这个问题
  + 执行`git clone https://github.com/NGY198888/JAVA.git`，会拉取到JAVA目录，
  + 将里面的.git复制到joy_common同级目录下
  + 执行`git reset --hard HEAD`，进行同步，下面就可以正常操作了
  + 执行`git add joy_common`
  + 执行`git commit -m "添加common"`
  + 执行`git push`没问题的话，jor_common就已经提交到GitHub了

# 使用bat提交
 + 新建一个.bat文件
 + 编写代码
    ``` cmd
    @echo off
    echo "-------请输入本次更新描述----------------"
    set /p msg=
    git add .
    git commit -m "提交修改 %msg%"
    git pull
    git push  origin source
    echo "--------提交完成--------------"
    pause
    ```
