```mermaid
erDiagram
    MEDIAS {
        int id PK
        string title
        string original_title
        float presse_score
        float viewer_score
        int sessions
        date exit_date
        int duration
        string synopsis
        string public
        string country
        string language
        string distributor
        int product_year
        string media_type
        int visa
    }
    GENDERS {
        int id PK
        string gender
    }
    PERSONS {
        int id PK
        string first_name
        string last_name
        string role
    }
    MEDIAS_GENDERS {
        int media_id FK "FK to MEDIAS"
        int gender_id FK "FK to GENDERS"
    }
    MEDIAS_PERSONS {
        int media_id FK "FK to MEDIAS"
        int person_id FK "FK to PERSONS"
    }

    MEDIAS ||--o{ MEDIAS_GENDERS : "has"
    GENDERS ||--o{ MEDIAS_GENDERS : "has"
    MEDIAS ||--o{ MEDIAS_PERSONS : "has"
    PERSONS ||--o{ MEDIAS_PERSONS : "has"