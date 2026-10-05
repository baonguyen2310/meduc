<div id="import-excel-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-md" role="document">
        <div class="modal-content">
            <div class="modal-header p-0 border-0"></div>

            <div class="modal-body">
                <h4 class="modal-title text-center">
                    {__d('admin', 'mau_file')}
                </h4>

                <p class="form-control-static text-center" nh-dowload-file-import>
                    {__d('admin', 'tai_mau_file_excel_va_nhap_thong_tin_san_pham')}
                    <i class="fa fa-file-csv d-block pointer-event mt-15" style="font-size: 3rem;"></i>
                </p>

                <form id="import-excel-product" action="{ADMIN_PATH}/product/import-excel" method="POST" autocomplete="off">
                    <div class="form-group mb-30">
                        <label>
                            {__d('admin', 'file_import')}
                        </label>
                        <div class="custom-file">
                            <input type="file" id="excel_file" name="excel_file" accept=".xlsx,.xls,.xlsm" class="custom-file-input">
                            <label class="custom-file-label selected" for="customFile"></label>
                        </div>
                    </div>

                    <div class="form-group text-center">
                        <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">
                            {__d('admin', 'dong')}
                        </button>
                        
                        <button id="btn-import-excel" type="button" class="btn btn-sm btn-primary">
                            {__d('admin', 'cap_nhat')}
                        </button>
                    </div>  
                </form>
            </div>
        </div>
    </div>
</div>