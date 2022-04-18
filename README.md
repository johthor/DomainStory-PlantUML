# Domain Storytelling with PlantUML

DomainStory-PlantUML uses [PlantUML](http://en.plantuml.com/) to describe and
document a domain story which was developed in a
[Domain Storytelling](http://www.domainstorytelling.org) workshop.

DomainStory-PlantUML includes macros for creating domain stories with PlantUML.

* [Getting Started](#getting-started)
* [Samples](#advanced-samples)
* [License](#license)

## Getting Started

At the top of your domain story PlantUML `.puml` file,
you need to include the `domainStory.puml` file
found in the root of this repository.

If you want to use the always up-to-date version in this repository,
use the following:

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
it is also possible to define system boundaries via`Boundary(name, [label])`.

![pictographic language](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/samples/pictographicLanguage.puml)

Now let's create our first domain story:

```puml
@startuml
!include https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/domainStory.puml

Boundary(System) {
    Person(Alice)
    Conversation(weather)
    Person(Bob)
}

activity(1, Alice, talks about the, weather, with, Bob)
@enduml
```

![basic sample](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/samples/basic.puml)

More information can be found here:

* [Domain Storytelling](http://www.domainstorytelling.org)
* [REAL WORLD PlantUML - Sample Gallery](https://real-world-plantuml.com/)

### Dynamic Creation of Work Objects

Instead of predefining all work objects,
they can also be defined on the fly when they are used.
Just prefix the work object with the kind of object you want to create
followed by a colon e.g. `Conversation:`.

Additionally, you can specify the color and scale of the created object
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

### Story Layout

For single story diagrams a landscape orientation is preferred
and is therefore the default orientation.
If you combine multiple stories into a domain journey,
a portrait orientation usually gives better results.
The orientation can be switched via `top to bottom direction` and `left to right direction` at the top of your file.

> :information_source: Wrangling diagram elements to an exact position
> or layout is not what PlantUML is for.

If the default layout does not please your inner artist,
there are some possibilities to improve it.

Group elements via `together { elements... }`.
Those elements will be grouped together.

The `activity` macro provides two features for better layout control.

The step counter can be combined with a backwards indicator `<`.
The following activity will be oriented backwards against the normal story flow.

```puml
activity(1<, Alice, talks about the, weather, with, Bob)
```

If this is not enough it also provides two optional parameters,
which allow you to specify the arrow orientation in full.
Some possible arrow specifications are `-->`, `->`, `<-`, `<--`, and `-up->`.
For more details
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

### Adding Notes

All elements support adding notes via the keyword argument `$note`.

```puml
Person(Alice, $note=fizz)
Conversation(weather, $note=buzz)
activity(1, Alice, talks about the, weather, with, Bob, $note=sunny)
```

In when adding a note on an activity,
the note will be added to the object of that activity.

Furthermore, the first symbol of the note text controls the orientation of it.
If its one of `^`, `<`, `v` or `>` the note will be placed
above, left, below or right of its element of reference.
Otherwise, it will be placed right of its element.

Notes to boundaries can't be added via the mechanism above.
So please use the basic PlantUML mechanism.

```puml
Boundary(wonderland) {
    Person(Alice)
}
note right of wonderland : Drink me
```

### Auto-Incrementing Steps

When describing activities the current step is automatically incremented,
if you pass an underscore `_` as step spec.
If instead you pass a vertical bar `|`,
the current step is declared as parallel to the last step,
and the step counter won't be incremented.

When you pass an integer value as step spec,
the step label will be set to that value.
If the integer is prefixed with an equal sign `=`,
the step counter will also be set to that value and auto-increment will continue from there.

```puml
activity(_, Bob, talks about the, weather) ' auto-increment, will create step 1
activity(_, Bob, talks about the, weather) ' auto-increment, will create step 2
activity(|, Bob, talks about the, weather) ' no increment, will create step 2
activity(42, Alice, asks about all the, talking, Bob) ' will create step 42
activity(|, Bob, talks about the, weather) ' no increment, will create step 2
activity(=10, Alice, asks about all the, talking, Bob) ' will create step 10
activity(_, Bob, is embarassed about, talking) ' auto-increment, will create step 11
```

### Styling

The following style definitions are used by default.

| Property         | Default Value | Description                                         |
|------------------|---------------|-----------------------------------------------------|
| `$textColor`     | `#0b0c10`     | Color of all text                                   |
| `$actorStyle`    | `default`     | Use outlines instead of filled icons for actors     |
| `$actorScale`    | `1`           | Size of all actors                                  |
| `$actorColor`    | `#1f2833`     | Color of all actors                                 |
| `$objectStyle`   | `default`     | Use outlines instead of filled icons for work items |
| `$objectScale`   | `0.8`         | Size of all work items                              |
| `$objectColor`   | `#1f2833`     | Color of all work items                             |
| `$boundaryColor` | `#1f2833`     | Color of boundary borders                           |
| `$activityColor` | `#c5c6c7`     | Color of the activity arrows                        |
| `$stepColor`     | `#66fcf1`     | Background color for step numbers                   |
| `$stepFontSize`  | `16`          | Font size for step numbers                          |
| `$stepFontColor` | `$textColor`  | Font color for step numbers, same as `$textColor`   |
| `$noteColor`     | `#c5c6c7`     | Background color for notes                          |
| `$noteBorder`    | `#1f2833`     | Border color for notes                              |

To use your own styling you need to define the relevant styling properties before including the library.
The following example would combine green actor icons with red text.

```puml
@startuml
!$textColor = "red"
!$actorColor = "green"

!include https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/domainStory.puml

Person(Alice)
@enduml
```

### Extensions

If the default actors and work objects are not enough to express your specific needs,
see the [extensions sample](samples/extensions.puml) for a way to add new actors and objects.

![extensions sample](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/samples/extensions.puml)

## Advanced Samples

### Cinema

The following example is taken from the [Domain Storytelling](http://www.domainstorytelling.org) website.

![cinema sample](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/samples/cinema.puml)

Source: [cinema.puml](samples/cinema.puml)

### Airport Bus

The following example is taken from _Collaborative Modelling -- Wie die
Kommunikation mit den Fachexperten gelingt_ JavaSPEKTRUM 2/2020.

![airport bus
sample](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/main/samples/airportBus.puml)

Source: [airportBus.puml](samples/airportBus.puml)

## License

This project is licensed under the MIT License

- see the [LICENSE](LICENSE) file for details

## Acknowledgements

- [C4-PlantUML](https://github.com/plantuml-stdlib/C4-PlantUML) an inspiration to implement a collection of domain story
  macros
- [@dirx improved domain story macros](https://gist.github.com/dirx/426e3099f07658965ee762cc70eba3cf) a more refined
  implementation of the first version
