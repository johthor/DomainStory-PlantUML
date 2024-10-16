# Domain Storytelling with PlantUML

DomainStory-PlantUML uses [PlantUML](http://en.plantuml.com/) to describe and
document a domain story which was developed in a
[Domain Storytelling](http://www.domainstorytelling.org) workshop.

## Table of Contents

* [Getting Started](#getting-started)
  * [Basic Story Layout](#basic-story-layout)
  * [Adding Notes or Annotations](#adding-notes-or-annotations)
  * [Auto-Incrementing Steps](#auto-incrementing-steps)
  * [Basic Styling](#basic-styling)
  * [Extensions](#extensions)
* [Advanced Features](#advanced-features)
  * [Dynamic Creation of Work Objects](#dynamic-creation-of-work-objects)
  * [Advanced Story Layout](#advanced-story-layout)
* [Advanced Samples](#advanced-samples)
  * [Cinema](#cinema)
  * [Airport Bus](#airport-bus)
* [License](#license)
* [Acknowledgements](#acknowledgements)

## Getting Started

At the top of your domain story PlantUML `.puml` file,
you need to include the `domainStory.puml` file found in the root of this repository.

The library is now part of the [PlantUML Standard Library](https://plantuml.com/en/stdlib)
and may be included via

```puml
!include <domainstory/Domainstory>
```

If you want to use the always up-to-date version in this repository,
use the following `include` definition

```puml
!include https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/domainStory.puml
```

To be independent of any internet connectivity,
you can also download the file found in the root
and reference it locally with

```puml
!include path/to/domainStory.puml
```

After you have included `domainStory.puml` you can use the predefined macro
definitions for the domain story actors:

* `Person(name, [label], [color], [scale], [note])`
* `Group(name, [label], [color], [scale], [note])`
* `System(name, [label], [color], [scale], [note])`

As well as the domain story work items:

* `Document(name, [label], [color], [scale], [note])`
* `Folder(name, [label], [color], [scale], [note])`
* `Call(name, [label], [color], [scale], [note])`
* `Email(name, [label], [color], [scale], [note])`
* `Conversation(name, [label], [color], [scale], [note])`
* `Info(name, [label], [color], [scale], [note])`

Activities between actors and involving work items are described via the `activity` macro:

```puml
activity(step, subject, predicate, object, [post], [target], [objectArr], [targetArr], [color], [scale], [note])
```

In addition to these,
it is also possible to define boundaries via`Boundary(name, [label], [backgroundColor], [note])`.

![pictographic language](assets/pictographicLanguage.svg)

Now let's create our first domain story:

```puml
@startuml
!include https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/domainStory.puml

Boundary(Party) {
    Person(Alice)
    Conversation(weather)
    Person(Bob)
}

activity(1, Alice, talks about the, weather, with, Bob)
@enduml
```

![basic sample](assets/basic.svg)

More information can be found here:

* [Domain Storytelling](http://www.domainstorytelling.org)
* [REAL WORLD PlantUML—Sample Gallery](https://real-world-plantuml.com/)


### Basic Story Layout

For single story diagrams, a landscape orientation is preferred
and is therefore the default orientation.
If you combine multiple stories into a domain journey,
a portrait orientation usually gives better results.
The orientation can be switched via `!$storyLayout = "[left-to-right|top-to-bottom]"` at the top of your file.

> :information_source: Wrangling diagram elements to an exact position
> or layout is not what PlantUML is for.

If the default layout does not please your inner artist,
there are some possibilities to improve it.

Group elements via `together { elements... }`.
Those elements will be grouped together.

The `activity` macro provides two features for better layout control.

Firs the step value can be combined with a direction indicator suffix

* `^` for UP
* `>` for RIGHT
* `v` for DOWN
* `<` LEFT
 
The following activity will be directed to the left of Alice.

```puml
activity(1<, Alice, talks about the, weather, with, Bob)
```

More details and the second activity direction feature will be discussed in [Advanced Story Layout](#advanced-story-layout).

### Adding Notes or Annotations

All elements support adding notes via the keyword argument `$note`.

```puml
Boundary(wonderland, $note=like Oxford) {
  Person(Alice, $note=fizz)
  Conversation(weather, $note=buzz)
  Person(Hatter)
  activity(1, Alice, talks about the, weather, with, Hatter, $note=sunny)
}
```

When adding a note on an activity,
the note will be added to the object of that activity.

Furthermore, the first symbol of the note text controls the orientation of it.
If its one of `^`, `>`, `v` or `<` the note will be placed
above, right, below or left of its element of reference.
Otherwise, it will be placed in the normal story direction of its element.

Notes may also be placed via the basic PlantUML mechanism.

```puml
Boundary(wonderland) {
    Person(Alice)
    Document(bottle)
}
note bottom of Alice : main character
note top of bottle : drink me
note right of wonderland : visit me
```

### Auto-Incrementing Steps

The activities will be numbered by default and may keep track of the current step number automatically.
Therefore, when describing activities,
the current step label supports multiple special value specifications to control the behavior.

| Step Value                 | Description                                                                                                               | Auto Increment |
|----------------------------|---------------------------------------------------------------------------------------------------------------------------|----------------|
| `_` _underscore_           | sequential step                                                                                                           | yes            |
| `\|` _bar_                 | parallel step                                                                                                             | no             |
| `.` _full stop_ / _period_ | hidden step counter                                                                                                       | no             |
| ` ` _space_ or '' _none_   | hidden step counter                                                                                                       | no             |
| `n` _any integer_          | step label will be `(n)`                                                                                                  | no             |
| `=n` _equal sign_ prefix   | step label will be `(n)`<br/>and step counter will be set to that integer<br/>and auto-increment will continue from there | no             |

See the following example for more details [step labels and auto increment](test/autoStepCounter.puml)

```puml
activity(_, Bob, talks about the, weather1) /' auto-increment will create step 1 '/
activity(_, Bob, talks about the, weather2) /' auto-increment will create step 2 '/
activity(|, Alice, talks about the, weather2) /' no increment will create step 2 '/
' will not create step, nor auto-increment, and will not display the step label
activity(.<, Bob, also talks about the, weather3)
activity(42, Alice, asks about all the, talking1, again, Bob) /' will create step 42 '/
activity(|, Bob, talks about the, weather4) /' no increment will still create step 2 '/
' will create step 10 and set the step counter to 10
activity(=10, Alice, talks about, talking2, Bob)
activity(_<, Bob, is embarrassed about, talking3) /' auto-increment will create step 11 '/
' will not create step, nor auto-increment, and will not display the step label
activity( , Alice, writes, mail, to, Bob)
```

### Basic Styling

The library is compatible with PlantUML themes like `sunlust` or `sketchy` and others.
Choose the theme before including the library.

If no theme is used, the following style definitions are used by default.

| Property         | Default Value   | Description                                         |
|------------------|-----------------|-----------------------------------------------------|
| `$storyLayout`   | `left-to-right` | Basic direction of the activity arrows              |
| `$textColor`     | `#0b0c10`       | Color of all text                                   |
| `$actorStyle`    | `default`       | Use outlines instead of filled icons for actors     |
| `$actorScale`    | `1`             | Size of all actors                                  |
| `$actorColor`    | `#1f2833`       | Color of all actors                                 |
| `$objectStyle`   | `default`       | Use outlines instead of filled icons for work items |
| `$objectScale`   | `0.8`           | Size of all work items                              |
| `$objectColor`   | `#1f2833`       | Color of all work items                             |
| `$boundaryColor` | `#1f2833`       | Color of boundary borders                           |
| `$activityColor` | `#c5c6c7`       | Color of the activity arrows                        |
| `$stepColor`     | `#66fcf1`       | Background color for step numbers                   |
| `$stepFontSize`  | `16`            | Font size for step numbers                          |
| `$stepFontColor` | `$textColor`    | Font color for step numbers, same as `$textColor`   |
| `$noteColor`     | `#c5c6c7`       | Background color for notes                          |
| `$noteBorder`    | `#1f2833`       | Border color for notes                              |

To use your own styling, you need to define the relevant styling properties before including the library.
The following example would combine green actor icons with red text.

```puml
@startuml
' !theme <theme name> /' optional '/

!$textColor = "red"
!$actorColor = "green"

!include https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/domainStory.puml

Person(Alice)
@enduml
```

> :information_source: You might want to set a matching `$stepColor` and `$stepFontColor` when using themes.

### Extensions

If the default actors and work objects are not enough to express your specific needs,
see the [extensions sample](samples/extensions.puml) for a way to add new actors and objects.

![extensions sample](assets/extensions.svg)

## Advanced Features

These features might come handy after you've used the library for quite some time.

### Dynamic Creation of Work Objects

Instead of predefining all work objects,
they can also be defined on the fly when they are used.
Prefix the work object with the kind of object you want to create
followed by a colon e.g. `Conversation:`.

Additionally, you can specify the color and scale of the created work object
via the keyword arguments `$color` and `$scale`

```puml
@startuml
!include https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/domainStory.puml

Boundary(System) {
    Person(Alice)
    Person(Bob)
    activity(1, Alice, talks about the, Conversation: weather, with, Bob, $color = red, $scale = 2)
}
@enduml
```

> :warning: **If you want your dynamically created objects to be placed inside a boundary.**
> You need to declare the activity inside said boundary.

### Advanced Story Layout

If the aforementioned lay-outing techniques described in [Basic Story Layout](#basic-story-layout) are not enough,
the `activity` macro supports more layout tricks.

In addition to the step counter specifications described above,
the step value may also specify the direction of the activity where `X` is one of the specifications above.

| Step Value                     | Description                                | Auto Increment |
|--------------------------------|--------------------------------------------|----------------|
| `X>` _greate-than sign_ suffix | direction of activity will be to the right | depends on X   |
| `X<` _less-than sign_ suffix   | direction of activity will be to the left  | depends on X   |
| `Xv` _vee_ suffix              | direction of activity will be downwards    | depends on X   |
| `X^` _caret_ suffix            | direction of activity will be upwards      | depends on X   |

See the tests for more details.

* [activity directions for left-to-right layout](test/activityDirection-leftToRight.puml)
* [activity directions for top-to-bottom layout](test/activityDirection-topToBottom.puml)
* [activity directions for both layouts](test/activityDirection-bothLayouts.puml)

Furthermore, the `activity` macro also provides two optional parameters,
which allow you to specify the arrow orientation in full details.

* `$objectArr` will define the arrow direction between the subject and the object
* and `$targetArr` will define the arrow direciton between the object and the target.

Some possible arrow specifications are `-->`, `->`, `<-`, `<--`, and `-up->`.
For more details,
see [The Hitchhiker's Guide to PlantUML](https://crashedmind.github.io/PlantUMLHitchhikersGuide/layout/layout.html#arrows-for-layout)
.

```puml
activity(1, Alice, talks about the, weather, with, Bob, -->, ->)
```

You can use underscores `_` in cases where you don't have a _post action_,
or _target_ but want to specify the arrow orientation directly.
When you specify only the arrow between subject and object,
the specification will also be used for the arrow between object and target.
So the following lines describe all more or less the same activity.

```puml
activity(1, Alice, talks about the, weather, , Bob, <--, <--)
activity(1, Alice, talks about the, weather, Bob, _, <--)
activity(1, Alice, talks about the, weather, _, _, <--)
```

If all of that does not help your layout problems,
there's always the possibility to introduce hidden connections
only for layout purposes.
Remember that every element of your story may be referenced by its name later.

```puml
Bob ---[hidden]-> Alice
```

## Advanced Samples

### Cinema

The following example is taken from the [Domain Storytelling](http://www.domainstorytelling.org) website.

![cinema sample](assets/cinema.svg)

Source: [cinema.puml](samples/cinema.puml)

### Airport Bus

The following example is taken from _Collaborative Modelling -- Wie die
Kommunikation mit den Fachexperten gelingt_ JavaSPEKTRUM 2/2020.

![airport bus
sample](assets/airportBus.svg)

Source: [airportBus.puml](samples/airportBus.puml)

## License

This project is licensed under the MIT License

- see the [LICENSE](LICENSE) file for details

## Acknowledgements

- [C4-PlantUML](https://github.com/plantuml-stdlib/C4-PlantUML) an inspiration to implement a collection of domain story
  macros
- [@dirx improved domain story macros](https://gist.github.com/dirx/426e3099f07658965ee762cc70eba3cf) a more refined
  implementation of the first version
