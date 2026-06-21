CLASS zcl_generator_track_test_fc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_generator_track_test_fc IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DELETE FROM zasset_status.
    DELETE FROM zassetfc.
    DELETE FROM zasset_dfc.

* Fill Status Data
    INSERT zasset_status FROM TABLE @( VALUE #( ( status_code        = '00'
                                                   status_description = 'Normal' )
                                                 ( status_code        = '01'
                                                   status_description = 'Damage' )
                                                 ( status_code        = '02'
                                                   status_description = 'Not match cost center' )
                                                 ( status_code        = '03'
                                                   status_description = 'Write off' )
                                                 ( status_code        = '04'
                                                   status_description = 'Sold' ) ) ).
    IF sy-subrc EQ 0.
      out->write( |{ sy-dbcnt } New Status were added| ).
    ENDIF.



    INSERT zassetfc FROM TABLE @( VALUE #( (  uuid              = cl_system_uuid=>create_uuid_x16_static( )
                                              asset_tag_number      =  '2100000404'
                                              asset_description     =  'Laptop Dell Latitude 5420'
                                              company_code          =  '0002'
                                              main_asset_number     =  '00'
                                              asset_sub_number      =  '00'
                                              status                =  '01'
                                    creation_date         = cl_abap_context_info=>get_system_date( )
                                    changed_date          = cl_abap_context_info=>get_system_date( )
                                    local_created_by      = cl_abap_context_info=>get_user_technical_name( )
                                    local_last_changed_by = cl_abap_context_info=>get_user_technical_name( )
                                    last_changed_at       = cl_abap_context_info=>get_system_time( ) ) ) ).


    IF sy-subrc EQ 0.
      out->write( |Travel.... { sy-dbcnt } rows inserted. | ).
    ENDIF.

*        et_incidents = value #( (   inc_uuid              = cl_system_uuid=>create_uuid_x16_static( )
*                                    incident_id           = lv_incident_id + 1
*                                    title                 = 'Network Outage'
*                                    description           = 'Widespread network issue affecting all users.'
*                                    status                = 'OP'
*                                    priority              = 'H'
*                                    creation_date         = cl_abap_context_info=>get_system_date( )
*                                    changed_date          = cl_abap_context_info=>get_system_date( )
*                                    local_created_by      = cl_abap_context_info=>get_user_technical_name( )
*                                    local_last_changed_by = cl_abap_context_info=>get_user_technical_name( )
*                                    last_changed_at       = cl_abap_context_info=>get_system_time( ) ).

  ENDMETHOD.
ENDCLASS.
