# PowerBuilder Deployment API

Инструмент для генерации Ant (.xml, .properties), PowerGen (.gen) и .pbt файлов по JSON описанию.

## Version 9.0.7
Добавлена визуальная часть, где можно выбирать `build.package.json` и генерить нужные файлы окружения.
Для запуска выполните `pb_deploy.exe` без параметров или запустите приложение из среды.

## Getting Started

Установить все зависимости

```
PowerGen
Java JDK 1.8
Ant 1.9.15
Git 2.25
PowerBuilder 9.0.3 build 8716
PushOk GITSCC
```

## Сборка проекта

Полная сборка производится с помощью *Ant'а* (см. *build.xml*).

```
cd pb_unit_test
ant clean make-project
```

Открыть проект в среде

```
pb90.exe pb-deploy.pbw
```

Запустить приложение

```
Основное меню -> Run -> Run pb_deploy (Ctrl+R)
```

## Описание работы утилиты
Для генерации то или иного файла, необходимо указать файл конфигурации приложения и тип генерируемого файла.
#### Файл конфигурации (build.package.json)
```text
{
  "name": string -- имя проекта,
  "version"?: string -- версия файла,
  "description"?: string -- описание проекта,
  -- Окружение приложения
  "application": {
    "name": string -- имя Application объекта,
    "library": string -- путь к библиотеке, где находится Application объект.pbl,
    "target": string -- наименование таргета.pbt,
	"ws": string -- наименование окружения.pbw
  },
  -- Данные для сборки приложения
  "deploy": {
    "exe": string -- имя исполняемого файла.exe,
    "pbr"?: string -- имя ресурс файла.pbr,
    "favicon"?: string -- иконка приложения.ico,
    "zip"?: string -- имя архива дистрибутива.zip,
    -- Массив каталогов ресурсов, где находятся файлы с маской - .bmp, .ico, .jpg, .jpeg, .gif, .cur
    "resources"?: [
      "путь к ресурсу, относительно рабочего каталога (например: resource\\icons, img и т.д.)"
    ]
  },
  -- Данные для запуска юнит тестов
  "test"?: {
      "script": string -- скрипт запуска юнит тестов (например: test.library=имя библиотеки)
  },
  -- Переменные для ant скрипта, которые сгенеряться в build.properties файл и их можно будет использовать в build.nested.xml
  -- Зарезервированные значения: project.name, project.executable, project.target, zip.package, test.script
  "antProperties": {
    -- Можно объявить как единичную запись
    "имя переменной": string -- значение,
    -- Можно объявить как объект
    "имя переменной": {
      "info": string -- описание,
      "value": string -- значение
    }
  },
  -- Описание библиотек приложения .pbl и .pbd
  -- В имени библиотек, при необходимости, можно указать её порядок (это важно для `PowerGen` сборки)
  -- Шаблон выглядит следующим образом - "[порядковый номер:]имя библиотеки.pb?" (например: "10:my_library.pbl")
  "libraries": {
    -- Разбивка библиотек по области окружения
    "scopes"?: {
      "область окружения": {
         "[порядковый номер:]имя библиотеки.pb?": string,
         "[порядковый номер:]имя библиотеки.pb?": {
           ...
         }
      }
    },
    -- Можно объявить как единичную запись
    "[порядковый номер:]имя библиотеки.pb?": string -- каталог библиотеки (указывать в начале .\ не надо),
                                 -- если библиотека находится в корне - то указываем ".",
    -- Можно объявить как объект
    "[порядковый номер:]имя библиотеки.pb?": {
      "dir": string -- каталог библиотеки,
      "scope": string -- область окружения, где будет применяться библиотека:
      -- default - по умолчанию, участвует в сборке (все фазы) и построении .pbt;
      -- test - участвует в 1ой фазе сборки, чтобы затем выполнить юнит тесты. Во 2ой фазе сборки, библиотека не участвует; 
      -- dev - библиотека только для разработки, в сборку она не попадет, но будет участвовать в построении .pbt;
      -- runtime - библиотека только для 1ой и 2ой фазы сборки, в .pbt не попадёт.
    }
  },
  -- Описание зависимостей, которые необходимо скачивать с nexus'а
  "dependencies"?: {
    "dir"?: string  -- каталог по умолчанию,
    -- Список подключаемых библиотек
    "libraries": {
      -- Можно объявить как единичную запись
      "groupId@artifactId": string -- номер версии,
      -- Можно объявить как объект
      "groupId@artifactId": {
        "version": string -- версия,
        "dir"?: string -- корневой каталог, куда загружать артефакт,
        "type": string -- тип артефакта
        "scope"?: string - область окружения, где будет применяться артефакт если его тип: `pbd`, `pbl`,
        "file"?: string - путь к файлу артефакта,
        "name"?: string - имя файла артефакта
        -- Если указано значение `file`, то параметры `name` и `dir` игнорируется, и артефакт будет сохранен по указнному
           -- пути с указанным именем (например: .\\canvas.pbx);
        -- Если указано значение `name`, то артефакт будет сохранен по пути `groupId/artifactId/version/${name}.type`;
        -- В остальный случаях, артефакт будет сохранен по пути `groupId/artifactId/version/artifactId-version.type`;
        -- Параметр `dir` определяет корень, для сформированного пути артефакта. Если значение не указано, то оно берётся
           -- с родителя `dependencies.dir`
      }
    },
    -- Список подключаемых пакетов (.zip архивов), в которых находятся артефакты
    "packages": {
      "groupId@artifactId": {
        "version": string -- версия,
        "dir"?: string -- корневой каталог, куда загружать артефакт(ы),
        "artifacts": {
          -- Можно объявить как единичную запись
          "artifactId": string -- тип артефакта,
          -- Можно объявить как объект
          "artifactId": {
             "dir"?: string -- корневой каталог, куда загружать артефакт,
             "type": string -- тип артефакта
             "scope"?: string - область окружения, где будет применяться артефакт если его тип: `pbd`, `pbl`,
             "file"?: string - путь к файлу артефакта,
             "name"?: string - имя файла артефакта
          }
        }
      }
    }   
  }
}
```

Пример файла конфигурации:
```json
{
  "name": "Some PowerBuilder Tools",
  "version": "1.0",
  "description": "Some tools and utilities for generate PowerScript code and save it to the .pb* files",
  "application": {
    "name": "some_tools",
    "library": "some_tools.pbl",
    "target": "some_tools.pbt",
	"ws": "some_tools.pbw"
  },
  "deploy": {
    "exe": "some_tools.exe",
    "pbr": "some_tools.pbr",
    "favicon": "favicon.ico",
    "zip": "some_tools.zip",
    "resources": [
      "resource\\icons",
      "resource\\images"
    ]
  },
  "libraries": {
    "scopes": {
      "dev": {
        "my_dev_library.pbl": "pbl.dev\\my_dev_library",
        "my_dev2_library.pbl": "pbl.dev\\my_dev2_library"
      },
      "runtime": {
        "my_runtime_library.pbd": "pbd",
        "my_runtime2_library.pbd": "pbd"
      }
    },
    "sometools.pbl": "",
    "app_map_viewer.pbl": "pbl\\app_map_viewer",
    "form_wizard.pbl": "pbl\\form_wizard",
    "pb_source_browser.pbl": "pbl\\pb_source_browser",
    "utils.pbl": "pbl\\utils",
    "tests.pbl": {
      "dir": "pbl.dev\\tests",
      "scope": "test"
    }
  },
  "dependencies": {
    "dir": "pbd",
    "libraries": {
        "ru.some.pb.dw-filter@dw-filter": "9.0.1",
        "ru.some.pb.json@json": "9.0.1",
        "ru.some.pb.unit-test@core": {
          "version": "9.0.1",
          "dir": "pbd.dev",
          "name": "pb_unit_test_core.pbd",
          "scope": "test"
        },
        "ru.some.pb.soap-client@soap-client": "9.0"
    },
    "packages": {
        "ru.some.pb.additional@additional-zip": {
          "version": "9.0.1",
          "artifacts": {
            "addon": "pbd",
            "common": "pbd",
            "io": "pbd"
          }
        }
    }
  }
}
```
#### Команды приложения
Делятся на несколько типов:
### deploy
* `/config.file=path` - файл конфигурации. Если значение не указано, то ищем `build.package.json`;
* `/gen:test=path` - генерируем `PowerGen` файл для сборки с тестами. Если значение не указано, то создаем `build.test.gen`;
* `/gen:dev=path` - генерируем `PowerGen` файл для девелоперской сборки. Если значение не указано, то создаем `build.dev.gen`;
* `/gen:release=path` - генерируем `PowerGen` файл для релизной сборки. Если значение не указано, то создаем `build.release.gen`;
* `/pbt=path` - генерируем PowerBuilder `target` файл. Если значение не указано, то имя берем из настройки `application.target`;
* `/pbw[.pbt]=path` - генерируем PowerBuilder `workspace` файл. Если значение не указано, то имя берем из настройки `application.ws`. Дополнительно можно указать имя `.pbt`, которое будет декларировано в `workspace` файле, если значение не указано, то берём из настройки `application.target`.
* `/pbr=path` - генерируем PowerBuilder `resource` файл. Если значение не указано, то имя берем из настройки `deploy.pbr` или генерим по `application.name.pbr`; Если блок `deploy.resources` не задан, то поиск ресурс-файлов будет осуществляться по `./resources` каталогу;
* `/ant:dependencies=path` - генерируем `xml` файл, в котором скачиваем зависимости с nexus'а. Если значение не указано, то создаем `build.download-dependencies.xml`;
* `/ant:properties=path` - генерируем `.properties` файл, в который сохраняем нужные свойства. Если значение не указано, то создает `build.properties`.
```spacebars
pb_deploy.exe deploy /config.file=d:\work\pb\ws\my_ws\build.package.json /gen:dev /pbr
```
### parse
* `/powergen.log=path` - разбор лога работы PowerGen утилиты. На выходе получаем `powergen.output.log` файл, где находятся только нужные данные.
```spacebars
pb_deploy.exe parse /powergen.log=d:\work\pb\ws\my_ws\powergen.log
```
