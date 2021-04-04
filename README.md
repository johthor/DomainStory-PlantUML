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
found in the `root` of this repo.

To be independent of any internet connectivity,
you can also download the files found in the `root`
and reference it locally with

```c#
!include path/to/domainStory.puml
```

Just remember to change the `!include` statements inside the top of the files.

If you want to use the always up-to-date version in this repo, use the following:

```c#
!includeurl https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/master/domainStory.puml
```

Now let's create a domain story diagram:

After you have included `domainStory.puml` you can use the defined macro
definitions for the domain story actors: `Person`, `Group`, and `System`.
As well as the work items: 
`Document`, `Folder`, `Call`, `Email`, `Conversation`, and `Info`

```csharp
@startuml Pictografic_Language
!includeurl https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/master/domainStory.puml

node actors
Person("PersonLabel")
Group("GroupLabel")
System("SystemLabel")

node "work objects"
Document("DocumentLabel") 
Folder("FolderLabel") 
Call("CallLabel") 
Email("EmailLabel") 
Conversation("ConversationLabel") 
Info("InfoLabel") 

@enduml
```

![pictografic language](http://www.plantuml.com/plantuml/png/JOz1J_Cm38Rl-HNzSiftOBbpciG08GrfqiGPUQdNPYHsvJXC-_UiA-sul4_ov5Lahuk2QCsfsSMWt0aSO_ZS0dKLEZJ_8eLKMwoIcbvrA8_U2vnNNTI-7cf12KoAfAl0sP-urvx5RpX3fBsoN1vs2KW_thS-Gr4KtzxVLaFDoHZY5Xi8LrFC3gKmEJjn2mTCzhzv5Qw3ipVCRdyfYjdPYRETFhDdbg-63oSCMgpPSAWPIPsTJx_rnhnmQb6SdRZe9qZ9sJ4NzPmXNjqDznxJDqe1ZUFGVszBvOsExEoOYp9hf7PS_GS0)

In addition to this,
it is also possible to define a system boundary.

Take a look a look at the following sample of a Domain Story:

```csharp
@startuml Basic Sample
!includeurl https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/master/domainStory.puml

Person(Alice)
Boundary(System) {
    Conversation(weather)
    Person(Bob)
}

activity(1, Alice, talks about, weather, with, Bob)

@enduml
```

![basic sample](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/master/samples/basic.puml)

More information can be found here:

* [Domain Storytelling](http://www.domainstorytelling.org)
* [REAL WORLD PlantUML - Sample Gallery](https://real-world-plantuml.com/)

## Advanced Samples

### Cinema

![cinema sample](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/master/samples/cinema.puml)

Source: [cinema.puml](samples/cinema.puml)

### Airport Bus

The following example is taken from _Collaborative Modelling -- Wie die
Kommunikation mit den Fachexperten gelingt_ JavaSPEKTRUM 2/2020.

![airport bus
sample](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/johthor/DomainStory-PlantUML/master/samples/airportBus.puml)

Source: [airportBus.puml](samples/airportBus.puml)

## License

This project is licensed under the MIT License
- see the [LICENSE](LICENSE) file for details
