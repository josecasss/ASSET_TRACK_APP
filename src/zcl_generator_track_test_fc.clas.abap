class zcl_generator_track_test_fc definition
  public
  final
  create public .

  public section.

    interfaces if_oo_adt_classrun .
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_GENERATOR_TRACK_TEST_FC IMPLEMENTATION.


  method if_oo_adt_classrun~main.

*    delete from zasset_status.
*
** Fill Status Data
*    insert zasset_status from table @( value #( ( status_code        = '00'
*                                                   status_description = 'Normal' )
*                                                 ( status_code        = '01'
*                                                   status_description = 'Damage' )
*                                                 ( status_code        = '02'
*                                                   status_description = 'Not match cost center' )
*                                                 ( status_code        = '03'
*                                                   status_description = 'Write off' )
*                                                 ( status_code        = '04'
*                                                   status_description = 'Sold' ) ) ).
*    if sy-subrc eq 0.
*      out->write( |{ sy-dbcnt } New Status were added| ).
*    endif.

    delete from zassetfc.
    delete from zasset_dfc.

    insert zassetfc from table @( value #( (  uuid              = cl_system_uuid=>create_uuid_x16_static( )
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


    if sy-subrc eq 0.
       out->write( |Travel.... { sy-dbcnt } rows inserted. | ).
    endif.

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
*                                    last_changed_at       = cl_abap_context_info=>get_system_time( ) )
    endmethod.
ENDCLASS.
