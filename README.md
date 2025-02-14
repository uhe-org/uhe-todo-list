# uhe To-Do List

> [!NOTE]  
> This skin needs the [uhe suite](https://github.com/uhe-org/uhe) in the same `Rainmeter/Skins` folder to work correctly.

Simple Rainmeter to-do list skin based on [Pernickety/rainmeter-todo-list](https://github.com/Pernickety/rainmeter-todo-list).

This is in the early stages of development.

> [!WARNING]  
> This can break in certain circumstances and you may lose all your data, so use at your own risk or backup the tasks txt files periodically.

## Usage

| Add Tasks | Complete Tasks | Clear Completed Tasks |
| --- | --- | --- |
|![Add Tasks](assets/addtasks.gif) | ![Complete Tasks](assets/completetasks.gif) | ![Clear Completed Tasks](assets/clearcompletetasks.gif) |

## Development

This repo is structured in a way to automate releases, but there is no way to have multiple custom skins folders in Rainmeter. It makes developing in real time not possible by default, and symlinking has to be done. For example in PowerShell as admin:

```powershell
New-Item -Path "$([Environment]::GetFolderPath("MyDocuments"))\Rainmeter\Skins\uhe-todo-list" -ItemType SymbolicLink -Value "$([Environment]::GetFolderPath("MyDocuments"))\GitHub\uhe-todo-list\RMSKIN\Skins\uhe-todo-list"
```
