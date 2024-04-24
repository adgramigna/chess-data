{% macro clean_player_name(player_name) -%}
    {%- set last_name -%}
        split_part( {{ player_name }}, ' ', 2)
    {%- endset -%}

    {%- set first_name -%}
        split_part({{ player_name }}, ' ', 1)
    {%- endset -%}

    case 
        when position(',' in {{ player_name }}) = 0 
        then {{ last_name }} || ', ' || {{ first_name }}
        else {{ player_name }}
    end
    
{%- endmacro %}